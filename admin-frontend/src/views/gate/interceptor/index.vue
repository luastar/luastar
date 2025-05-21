<!-- 拦截器管理 -->
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
        <el-table-column label="编码" prop="code" width="200" />
        <el-table-column label="名称" prop="name" width="200" />
        <el-table-column label="拦截路由" prop="routes" width="400" />
        <el-table-column label="排除路由" prop="routes_exclude" width="400" />
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

    <!-- 拦截器表单 -->
    <el-drawer
      v-model="dialog.visible"
      :title="dialog.title"
      append-to-body
      :size="drawerSize"
      @close="handleCloseDialog"
    >
      <el-form ref="editFormRef" :model="formData" :rules="rules" label-width="120px">
        <el-form-item label="级别" prop="level">
          <el-select
            v-model="formData.level"
            :readonly="!!formData.id"
            placeholder="请输入级别"
            clearable
          >
            <el-option
              v-for="item in LevelOptions"
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

        <el-form-item prop="routes">
          <template #label>
            <span>
              拦截路由
              <el-tooltip
                content='形如[{"path":"^/api/admin/.*","method":"*","mode":"p(精确匹配)|v(正则匹配)"}]的json数组格式。'
              >
                <QuestionFilled class="w-4 h-4 mx-1" />
              </el-tooltip>
            </span>
          </template>
          <el-input
            v-model="formData.routes"
            type="textarea"
            :rows="4"
            placeholder="请输入拦截路由"
          />
        </el-form-item>

        <el-form-item label="排除路由" prop="routes_exclude" tooltip="json数组">
          <template #label>
            <span>
              拦截路由
              <el-tooltip content="json数组。">
                <QuestionFilled class="w-4 h-4 mx-1" />
              </el-tooltip>
            </span>
          </template>
          <el-input
            v-model="formData.routes_exclude"
            type="textarea"
            :rows="6"
            placeholder="请输入排除路由"
          />
        </el-form-item>

        <el-form-item label="模块编码" prop="mcode">
          <el-autocomplete
            v-model="formData.mcode"
            :fetch-suggestions="handleModuleSearch"
            clearable
            placeholder="请输入模块编码"
            value-key="code"
          />
        </el-form-item>

        <el-form-item label="前置函数" prop="mfunc_before">
          <el-autocomplete
            v-model="formData.mfunc_before"
            :fetch-suggestions="handleFuncSearch"
            clearable
            placeholder="请输入前置函数"
            value-key="code"
            @focus="handleFuncFocus"
          />
        </el-form-item>

        <el-form-item label="后置函数" prop="mfunc_after">
          <el-autocomplete
            v-model="formData.mfunc_after"
            :fetch-suggestions="handleFuncSearch"
            clearable
            placeholder="请输入后置函数"
            value-key="code"
            @focus="handleFuncFocus"
          />
        </el-form-item>

        <el-form-item label="参数" prop="params">
          <el-input v-model="formData.params" type="textarea" :rows="4" placeholder="请输入参数" />
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
import { useAppStore } from "@/store/modules/app.store";
import { DeviceEnum, LevelOptions } from "@/enums";

import InterceptorAPI, {
  InterceptorForm,
  InterceptorPageQuery,
  InterceptorPageVO,
} from "@/api/gate/interceptor.api";
import ModuleAPI, { CodeName } from "@/api/gate/module.api";

defineOptions({
  name: "Interceptor",
  inheritAttrs: false,
});

const appStore = useAppStore();

const queryFormRef = ref();
const editFormRef = ref();

const queryParams = reactive<InterceptorPageQuery>({
  pageNum: 1,
  pageSize: 10,
});

const pageData = ref<InterceptorPageVO[]>();
const total = ref(0);
const loading = ref(false);

const dialog = reactive({
  visible: false,
  title: "新增拦截器",
});
const drawerSize = computed(() => (appStore.device === DeviceEnum.DESKTOP ? "600px" : "90%"));

const formData = reactive<InterceptorForm>({
  level: "user",
  code: "",
  routes: "",
  mcode: "",
  mfunc_before: "",
  mfunc_after: "",
  state: "enable",
});

const rules = reactive({
  level: [{ required: true, message: "级别不能为空", trigger: "blur" }],
  code: [{ required: true, message: "编码不能为空", trigger: "blur" }],
  name: [{ required: true, message: "名称不能为空", trigger: "blur" }],
  routes: [{ required: true, message: "拦截路由不能为空", trigger: "blur" }],
  mcode: [{ required: true, message: "模块编码不能为空", trigger: "blur" }],
  mfunc_before: [{ required: true, message: "前置函数不能为空", trigger: "blur" }],
  mfunc_after: [{ required: true, message: "后置函数不能为空", trigger: "blur" }],
  state: [{ required: true, message: "状态不能为空", trigger: "blur" }],
});

// 选中的拦截器ID
const selectIds = ref<string[]>([]);

// 代码提示数据
const moduleOptions = ref<CodeName[]>([]);
const moduleFuncOptions = ref<CodeName[]>([]);

// 查询
async function handleQuery() {
  loading.value = true;
  queryParams.pageNum = 1;
  InterceptorAPI.getPage(queryParams)
    .then((data) => {
      pageData.value = data.list;
      total.value = data.total;
    })
    .finally(() => {
      loading.value = false;
    });
}

// 初始化选项
async function initOptions() {
  ModuleAPI.getHintModuleList("interceptor").then((data) => {
    moduleOptions.value = data;
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
 * @param id 拦截器ID
 */
async function handleOpenDialog(id?: string) {
  dialog.visible = true;
  await initOptions();
  if (id) {
    dialog.title = "修改拦截器";
    InterceptorAPI.getFormData(id).then((data) => {
      Object.assign(formData, { ...data });
    });
  } else {
    dialog.title = "新增拦截器";
    // 设置默认值
    formData.level = "user";
    formData.state = "enable";
    InterceptorAPI.getMaxRank()
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

// 提交拦截器表单（防抖）
const handleSubmit = useDebounceFn(() => {
  editFormRef.value.validate((valid: boolean) => {
    if (valid) {
      const id = formData.id;
      loading.value = true;
      if (id) {
        InterceptorAPI.update(id, formData)
          .then(() => {
            ElMessage.success("修改拦截器成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      } else {
        InterceptorAPI.create(formData)
          .then(() => {
            ElMessage.success("新增拦截器成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      }
    }
  });
}, 1000);

/**
 * 删除拦截器
 *
 * @param id  拦截器ID
 */
function handleDelete(id?: string) {
  const ids = id ? [id] : selectIds.value;
  if (!ids) {
    ElMessage.warning("请勾选删除项");
    return;
  }

  ElMessageBox.confirm("确认删除拦截器?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(
    function () {
      loading.value = true;
      InterceptorAPI.deleteByIds(ids)
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

// 代码模块提示
function handleModuleSearch(queryString: string, cb: any) {
  const results = queryString
    ? moduleOptions.value.filter(handleModuleFilter(queryString))
    : moduleOptions.value;
  cb(results);
}

// 代码模块提示过滤
function handleModuleFilter(queryString: string) {
  return (module: CodeName) => {
    return module.code.toLowerCase().includes(queryString.toLowerCase());
  };
}

// 代码模块函数搜索
function handleFuncSearch(queryString: string, cb: any) {
  const results = queryString
    ? moduleFuncOptions.value.filter(handleFuncFilter(queryString))
    : moduleFuncOptions.value;
  cb(results);
}

// 代码模块函数提示过滤
function handleFuncFilter(queryString: string) {
  return (func: CodeName) => {
    return func.code.toLowerCase().includes(queryString.toLowerCase());
  };
}

// 代码模块函数提示聚焦
function handleFuncFocus() {
  ModuleAPI.getHintModuleFuncList(formData.mcode).then((data) => {
    moduleFuncOptions.value = data;
  });
}

onMounted(() => {
  handleQuery();
});
</script>
