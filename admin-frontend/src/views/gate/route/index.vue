<!-- 路由管理 -->
<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <div class="search-container">
      <el-form ref="queryFormRef" :model="queryParams" :inline="true" label-width="auto">
        <el-form-item label="级别" prop="level">
          <el-select v-model="queryParams.level" placeholder="全部" clearable style="width: 100px">
            <el-option
              v-for="item in levelOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="类型" prop="type">
          <el-select v-model="queryParams.type" placeholder="全部" clearable style="width: 100px">
            <el-option
              v-for="item in typeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="编码" prop="code">
          <el-input v-model="queryParams.code" placeholder="请输入编码" />
        </el-form-item>

        <el-form-item label="名称" prop="name">
          <el-input v-model="queryParams.name" placeholder="请输入名称" />
        </el-form-item>

        <el-form-item label="路径" prop="path">
          <el-input v-model="queryParams.path" placeholder="请输入路径" />
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
        <el-table-column label="类型" prop="type" width="160" />
        <el-table-column label="编码" prop="code" width="200" />
        <el-table-column label="名称" prop="name" width="200" />
        <el-table-column label="路径" prop="path" width="300" />
        <el-table-column label="请求方法" prop="method" width="100" />
        <el-table-column label="匹配模式" prop="mode" width="100" />
        <el-table-column label="状态" prop="state" width="80">
          <template #default="scope">
            <el-tag :type="scope.row.state == 'enable' ? 'success' : 'info'">
              {{ scope.row.state == "enable" ? "启用" : "停用" }}
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

    <!-- 路由表单 -->
    <el-drawer
      v-model="dialog.visible"
      :title="dialog.title"
      append-to-body
      :size="drawerSize"
      @close="handleCloseDialog"
    >
      <el-form ref="editFormRef" :model="formData" :rules="rules" label-width="80px">
        <el-form-item label="级别" prop="level">
          <el-select
            v-model="formData.level"
            :readonly="!!formData.id"
            placeholder="请输入级别"
            clearable
          >
            <el-option
              v-for="item in levelOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="类型" prop="type">
          <el-select v-model="formData.type" placeholder="请输入类型" clearable>
            <el-option
              v-for="item in typeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="编码" prop="code">
          <el-input v-model="formData.code" placeholder="请输入编码" />
        </el-form-item>

        <el-form-item label="名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入名称" />
        </el-form-item>

        <el-form-item label="路径" prop="path">
          <el-input v-model="formData.path" placeholder="请输入路径" />
        </el-form-item>

        <el-form-item label="请求方法" prop="method">
          <CustomMultiSelect v-model="formData.method" multiple placeholder="请选择请求方法">
            <el-option
              v-for="item in methodOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </CustomMultiSelect>
        </el-form-item>

        <el-form-item label="匹配方式" prop="mode">
          <el-select v-model="formData.mode" placeholder="请选择匹配方式" clearable>
            <el-option
              v-for="item in modeOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            ></el-option>
          </el-select>
        </el-form-item>

        <el-form-item label="模块编码" prop="mcode">
          <el-input v-model="formData.mcode" placeholder="请输入模块编码" />
        </el-form-item>

        <el-form-item label="模块函数" prop="mfunc">
          <el-input v-model="formData.mfunc" placeholder="请输入模块函数" />
        </el-form-item>

        <el-form-item label="参数" prop="params">
          <el-input v-model="formData.params" placeholder="请输入参数" />
        </el-form-item>

        <el-form-item label="状态" prop="state">
          <el-switch
            v-model="formData.state"
            inline-prompt
            active-text="正常"
            inactive-text="禁用"
            :active-value="'enable'"
            :inactive-value="'disable'"
          />
        </el-form-item>
      </el-form>

      <el-form-item label="排序" prop="rank">
        <el-input-number v-model="formData.rank" label="请输入排序" />
      </el-form-item>

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
import CustomMultiSelect from "@/components/CustomMultiSelect/index.vue";
import { useAppStore } from "@/store/modules/app.store";
import { DeviceEnum } from "@/enums/settings/device.enum";

import RouteAPI, { RouteForm, RoutePageQuery, RoutePageVO } from "@/api/gate/route.api";
import ConfigAPI from "@/api/gate/config.api";

defineOptions({
  name: "Route",
  inheritAttrs: false,
});

const appStore = useAppStore();

const queryFormRef = ref();
const editFormRef = ref();

const queryParams = reactive<RoutePageQuery>({
  pageNum: 1,
  pageSize: 10,
});

const pageData = ref<RoutePageVO[]>();
const total = ref(0);
const loading = ref(false);

const dialog = reactive({
  visible: false,
  title: "新增路由",
});
const drawerSize = computed(() => (appStore.device === DeviceEnum.DESKTOP ? "600px" : "90%"));

const formData = reactive<RouteForm>({
  level: "user",
  code: "",
  path: "",
  state: "enable",
});

const rules = reactive({
  level: [{ required: true, message: "级别不能为空", trigger: "blur" }],
  code: [{ required: true, message: "编码不能为空", trigger: "blur" }],
  name: [{ required: true, message: "名称不能为空", trigger: "blur" }],
  path: [{ required: true, message: "路径不能为空", trigger: "blur" }],
  mcode: [{ required: true, message: "模块编码不能为空", trigger: "blur" }],
  mfunc: [{ required: true, message: "模块函数不能为空", trigger: "blur" }],
  state: [{ required: true, message: "状态不能为空", trigger: "blur" }],
});

// 选中的路由ID
const selectIds = ref<string[]>([]);
// 级别下拉数据源
const levelOptions: OptionType[] = [
  { label: "系统", value: "system" },
  { label: "用户", value: "user" },
];
// 类型下拉数据源
const typeOptions = ref<OptionType[]>();
// 请求方法下拉数据源
const methodOptions: OptionType[] = [
  { label: "全部", value: "*" },
  { label: "GET", value: "GET" },
  { label: "POST", value: "POST" },
  { label: "PUT", value: "PUT" },
  { label: "DELETE", value: "DELETE" },
  { label: "PATCH", value: "PATCH" },
  { label: "HEAD", value: "HEAD" },
  { label: "OPTIONS", value: "OPTIONS" },
  { label: "TRACE", value: "TRACE" },
  { label: "CONNECT", value: "CONNECT" },
];
// 匹配方式下拉数据源
const modeOptions: OptionType[] = [
  { label: "完全匹配", value: "p" },
  { label: "模糊匹配", value: "v" },
];

// 查询
async function handleQuery() {
  loading.value = true;
  handleQueryOptions();
  queryParams.pageNum = 1;
  RouteAPI.getPage(queryParams)
    .then((data) => {
      pageData.value = data.list;
      total.value = data.total;
    })
    .finally(() => {
      loading.value = false;
    });
}

// 查询类型选项
async function handleQueryOptions() {
  ConfigAPI.getConfigContent<OptionType[]>("route.type").then((data) => {
    typeOptions.value = data;
  });
}

// 重置查询
function handleResetQuery() {
  queryFormRef.value.resetFields();
  queryParams.pageNum = 1;
  queryParams.level = undefined;
  queryParams.type = undefined;
  queryParams.code = undefined;
  queryParams.name = undefined;
  queryParams.path = undefined;
  handleQuery();
}

// 选中项发生变化
function handleSelectionChange(selection: any[]) {
  selectIds.value = selection.map((item) => item.id);
}

/**
 * 打开弹窗
 *
 * @param id 路由ID
 */
async function handleOpenDialog(id?: string) {
  dialog.visible = true;
  // 加载类型下拉数据源
  await handleQueryOptions();
  if (id) {
    dialog.title = "修改路由";
    RouteAPI.getFormData(id).then((data) => {
      Object.assign(formData, { ...data });
    });
  } else {
    dialog.title = "新增路由";
    // 设置默认值
    formData.level = "user";
    formData.method = "*";
    formData.mode = "p";
    formData.state = "enable";
    // 获取最大排序值并设置默认值
    RouteAPI.getMaxRank()
      .then((maxRank) => {
        formData.rank = (maxRank || 0) + 1;
      })
      .catch(() => {
        formData.rank = 1; // 默认值
      });
  }
}

// 关闭弹窗
function handleCloseDialog() {
  dialog.visible = false;
  editFormRef.value.resetFields();
  editFormRef.value.clearValidate();
  formData.id = undefined;
}

// 提交路由表单（防抖）
const handleSubmit = useDebounceFn(() => {
  editFormRef.value.validate((valid: boolean) => {
    if (valid) {
      const id = formData.id;
      loading.value = true;
      if (id) {
        RouteAPI.update(id, formData)
          .then(() => {
            ElMessage.success("修改路由成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      } else {
        RouteAPI.create(formData)
          .then(() => {
            ElMessage.success("新增路由成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      }
    }
  });
}, 1000);

/**
 * 删除路由
 *
 * @param id  路由ID
 */
function handleDelete(id?: string) {
  const ids = id ? [id] : selectIds.value;
  if (!ids) {
    ElMessage.warning("请勾选删除项");
    return;
  }

  ElMessageBox.confirm("确认删除路由?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(
    function () {
      loading.value = true;
      RouteAPI.deleteByIds(ids)
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
