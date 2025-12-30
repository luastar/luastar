<!-- 配置管理 -->
<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <div class="search-container">
      <el-form ref="queryFormRef" :model="queryParams" :inline="true" label-width="80px">
        <el-form-item label="级别" prop="level">
          <el-select v-model="queryParams.level" placeholder="全部" clearable style="width: 100px">
            <el-option
              v-for="item in LevelOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="类型" prop="type">
          <el-input v-model="queryParams.type" placeholder="请输入类型" />
        </el-form-item>

        <el-form-item label="编码" prop="code">
          <el-input v-model="queryParams.code" placeholder="请输入编码" />
        </el-form-item>

        <el-form-item label="名称" prop="name">
          <el-input v-model="queryParams.name" placeholder="请输入名称" />
        </el-form-item>

        <el-form-item class="search-buttons">
          <el-button type="primary" icon="search" @click="handleQuery">搜索</el-button>
          <el-button icon="refresh" @click="handleResetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card shadow="hover" class="data-table">
      <div class="data-table__toolbar">
        <div class="data-table__toolbar--actions">
          <el-button type="success" icon="plus" @click="handleOpenDialog()">新增</el-button>
          <el-button
            type="danger"
            icon="delete"
            :disabled="selectIds.length === 0"
            @click="handleDelete()"
          >
            删除
          </el-button>
        </div>
        <div class="data-table__toolbar--tools"></div>
      </div>

      <el-table
        v-loading="loading"
        :data="pageData"
        border
        stripe
        highlight-current-row
        class="data-table__content"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="50" align="center" />
        <el-table-column label="级别" prop="level" width="100" />
        <el-table-column label="类型" prop="type" width="100" />
        <el-table-column label="编码" prop="code" width="200" />
        <el-table-column label="名称" prop="name" width="200" />
        <el-table-column label="值类型" prop="vtype" width="100">
          <template #default="scope">
            <el-tag>{{ scope.row.vtype }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="值内容" prop="vcontent" width="300">
          <template #default="scope">
            <el-tooltip :content="scope.row.vcontent" placement="top" :show-after="500">
              <span class="truncate inline-block max-w-[200px]">{{ scope.row.vcontent }}</span>
            </el-tooltip>
          </template>
        </el-table-column>
        <el-table-column label="状态" prop="state" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.state === 'enable' ? 'success' : 'danger'">
              {{ scope.row.state === "enable" ? "启用" : "停用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="排序" prop="rank" width="100" />
        <el-table-column label="操作" fixed="right" width="220">
          <template #default="scope">
            <el-button
              type="primary"
              icon="edit"
              link
              size="small"
              @click="handleOpenDialog(scope.row.id)"
            >
              编辑
            </el-button>
            <el-button
              type="danger"
              icon="delete"
              link
              size="small"
              @click="handleDelete(scope.row.id)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <pagination
        v-if="total > 0"
        v-model:total="total"
        v-model:page="queryParams.pageNum"
        v-model:limit="queryParams.pageSize"
        @pagination="handleQuery"
      />
    </el-card>

    <!-- 配置表单 -->
    <el-drawer
      v-model="dialog.visible"
      :title="dialog.title"
      append-to-body
      :size="drawerSize"
      @close="handleCloseDialog"
    >
      <el-form ref="editFormRef" :model="formData" :rules="rules" label-width="80px">
        <el-form-item label="级别" prop="level">
          <el-select v-model="formData.level" placeholder="请选择级别" clearable>
            <el-option
              v-for="item in LevelOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="类型" prop="type">
          <el-input v-model="formData.type" placeholder="请输入类型" />
        </el-form-item>

        <el-form-item label="编码" prop="code">
          <el-input v-model="formData.code" placeholder="请输入编码" />
        </el-form-item>

        <el-form-item label="名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入名称" />
        </el-form-item>

        <el-form-item label="值类型" prop="vtype">
          <el-select v-model="formData.vtype" placeholder="请选择值类型" clearable>
            <el-option
              v-for="item in vtypeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="值内容" prop="vcontent">
          <!-- 字符串类型 -->
          <el-input
            v-if="formData.vtype === ConfigVType.STRING"
            v-model="formData.vcontent"
            placeholder="请输入字符串值"
          />
          <!-- 布尔类型 -->
          <el-switch
            v-else-if="formData.vtype === ConfigVType.BOOLEAN"
            v-model="formData.vcontent"
            active-text="true"
            inactive-text="false"
            :active-value="String(true)"
            :inactive-value="String(false)"
          />
          <!-- 数值类型 -->
          <el-input-number
            v-else-if="formData.vtype === ConfigVType.NUMBER"
            v-model="numberValue"
            :precision="0"
            :controls="true"
            placeholder="请输入数值"
          />
          <!-- 对象/数组类型 -->
          <el-input
            v-else
            v-model="formData.vcontent"
            type="textarea"
            :rows="8"
            placeholder="请输入JSON格式的对象或数组"
          />
        </el-form-item>

        <el-form-item label="状态" prop="state">
          <el-switch
            v-model="formData.state"
            inline-prompt
            active-text="启用"
            inactive-text="停用"
            :active-value="'enable'"
            :inactive-value="'disable'"
          />
        </el-form-item>

        <el-form-item label="排序" prop="rank">
          <el-input-number v-model="formData.rank" :min="0" />
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="handleSubmit">确 定</el-button>
          <el-button @click="handleCloseDialog">取 消</el-button>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { useAppStore } from "@/store/modules/app.store";
import { DeviceEnum, LevelOptions } from "@/enums";
import ConfigAPI, {
  ConfigVType,
  ConfigForm,
  ConfigPageQuery,
  ConfigPageVO,
} from "@/api/gate/config.api";

defineOptions({
  name: "Config",
  inheritAttrs: false,
});

const appStore = useAppStore();

const queryFormRef = ref();
const editFormRef = ref();

const queryParams = reactive<ConfigPageQuery>({
  pageNum: 1,
  pageSize: 10,
});

const pageData = ref<ConfigPageVO[]>();
const total = ref(0);
const loading = ref(false);

const dialog = reactive({
  visible: false,
  title: "新增配置",
});
const drawerSize = computed(() => (appStore.device === DeviceEnum.DESKTOP ? "600px" : "90%"));

const formData = reactive<ConfigForm>({
  level: "user",
  code: "",
  name: "",
  vtype: ConfigVType.STRING,
  vcontent: "",
  state: "enable",
});

// 初始化标志位
const isInitializing = ref(false);

// 数值类型的计算属性
const numberValue = computed({
  get: () => {
    if (formData.vtype === ConfigVType.NUMBER) {
      return Number(formData.vcontent) || 0;
    }
    return 0;
  },
  set: (value) => {
    formData.vcontent = String(value);
  },
});

const rules = reactive({
  level: [{ required: true, message: "级别不能为空", trigger: "blur" }],
  type: [{ required: true, message: "类型不能为空", trigger: "blur" }],
  code: [{ required: true, message: "编码不能为空", trigger: "blur" }],
  name: [{ required: true, message: "名称不能为空", trigger: "blur" }],
  vtype: [{ required: true, message: "值类型不能为空", trigger: "blur" }],
  vcontent: [{ required: true, message: "值内容不能为空", trigger: "blur" }],
});

// 选中的配置ID
const selectIds = ref<string[]>([]);

// 值类型下拉数据源
const vtypeOptions: OptionType[] = [
  { label: "字符串", value: ConfigVType.STRING },
  { label: "数字", value: ConfigVType.NUMBER },
  { label: "布尔值", value: ConfigVType.BOOLEAN },
  { label: "对象", value: ConfigVType.OBJECT },
  { label: "数组", value: ConfigVType.ARRAY },
];

// 查询
async function handleQuery() {
  loading.value = true;
  ConfigAPI.getPage(queryParams)
    .then((data) => {
      pageData.value = data.list;
      total.value = data.total;
    })
    .finally(() => {
      loading.value = false;
    });
}

// 重置查询
function handleResetQuery() {
  queryFormRef.value.resetFields();
  queryParams.pageNum = 1;
  handleQuery();
}

// 选中项发生变化
function handleSelectionChange(selection: any[]) {
  selectIds.value = selection.map((item) => item.id);
}

/**
 * 打开弹窗
 *
 * @param id 配置ID
 */
async function handleOpenDialog(id?: string) {
  dialog.visible = true;
  isInitializing.value = true;
  if (id) {
    dialog.title = "修改配置";
    await ConfigAPI.getFormData(id).then((data) => {
      Object.assign(formData, { ...data });
    });
  } else {
    dialog.title = "新增配置";
    // 设置默认值
    formData.level = "user";
    formData.vtype = ConfigVType.STRING;
    formData.state = "enable";
    await ConfigAPI.getMaxRank()
      .then((maxRank) => {
        formData.rank = (maxRank || 0) + 1;
      })
      .catch(() => {
        formData.rank = 1; // 默认值
      });
  }
  isInitializing.value = false;
}

// 关闭弹窗
function handleCloseDialog() {
  dialog.visible = false;
  editFormRef.value.resetFields();
  editFormRef.value.clearValidate();
  formData.id = undefined;
}

// 监听值类型变化
watch(
  () => formData.vtype,
  (newType, oldType) => {
    if (newType !== oldType && !isInitializing.value) {
      // 只在非初始化阶段设置默认值
      // 根据新类型设置默认值
      switch (newType) {
        case ConfigVType.STRING:
          formData.vcontent = "";
          break;
        case ConfigVType.NUMBER:
          formData.vcontent = "0";
          break;
        case ConfigVType.BOOLEAN:
          formData.vcontent = String(false);
          break;
        case ConfigVType.OBJECT:
          formData.vcontent = "{}";
          break;
        case ConfigVType.ARRAY:
          formData.vcontent = "[]";
          break;
      }
    }
  }
);

// 提交前验证值内容格式
const validateValueContent = () => {
  try {
    const vtype = formData.vtype;
    const vcontent = formData.vcontent;

    if (vtype === ConfigVType.NUMBER) {
      if (isNaN(Number(vcontent))) {
        ElMessage.error("值内容必须是数字");
        return false;
      }
    } else if (vtype === ConfigVType.BOOLEAN) {
      if (vcontent !== String(true) && vcontent !== String(false)) {
        ElMessage.error("值内容必须是布尔值");
        return false;
      }
    } else if (vtype === ConfigVType.OBJECT || vtype === ConfigVType.ARRAY) {
      try {
        const parsed = JSON.parse(vcontent);
        if (vtype === ConfigVType.OBJECT && !isObject(parsed)) {
          ElMessage.error("值内容必须是有效的JSON对象");
          return false;
        }
        if (vtype === ConfigVType.ARRAY && !Array.isArray(parsed)) {
          ElMessage.error("值内容必须是有效的JSON数组");
          return false;
        }
        // 格式化JSON字符串
        formData.vcontent = JSON.stringify(parsed, null, 2);
      } catch (_error) {
        ElMessage.error("值内容必须是有效的JSON格式");
        return false;
      }
    }
    return true;
  } catch (_error) {
    ElMessage.error("值内容格式验证失败");
    return false;
  }
};

// 判断是否为对象
const isObject = (value: any) => {
  return value !== null && typeof value === "object" && !Array.isArray(value);
};

// 提交配置表单（防抖）
const handleSubmit = useDebounceFn(() => {
  editFormRef.value.validate((valid: boolean) => {
    if (valid && validateValueContent()) {
      const id = formData.id;
      loading.value = true;
      if (id) {
        ConfigAPI.update(id, formData)
          .then(() => {
            ElMessage.success("修改配置成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      } else {
        ConfigAPI.create(formData)
          .then(() => {
            ElMessage.success("新增配置成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      }
    }
  });
}, 1000);

/**
 * 删除配置
 *
 * @param id  配置ID
 */
function handleDelete(id?: string) {
  const ids = id ? [id] : selectIds.value;
  if (!ids || ids.length === 0) {
    ElMessage.warning("请勾选删除项");
    return;
  }

  ElMessageBox.confirm("确认删除选中的配置?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(
    function () {
      loading.value = true;
      ConfigAPI.deleteByIds(ids)
        .then(() => {
          ElMessage.success("删除成功");
          handleResetQuery();
        })
        .finally(() => (loading.value = false));
    },
    function () {
      ElMessage.info("已取消删除");
    }
  );
}

onMounted(() => {
  handleQuery();
});
</script>
