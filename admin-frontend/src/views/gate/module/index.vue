<!-- 代码管理 -->
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

    <!-- 代码表单 -->
    <el-drawer
      v-model="dialog.visible"
      :title="dialog.title"
      append-to-body
      :size="drawerSize"
      @open="onOpenDialog"
      @close="handleCloseDialog"
    >
      <el-form ref="editFormRef" :model="formData" :rules="rules" label-width="60px">
        <el-row>
          <el-col :span="8">
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

            <el-form-item label="描述" prop="desc">
              <el-input
                v-model="formData.desc"
                type="textarea"
                :rows="8"
                placeholder="请输入描述"
              />
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

            <el-form-item label="排序" prop="rank">
              <el-input-number v-model="formData.rank" label="请输入排序" />
            </el-form-item>
          </el-col>
          <el-col :span="16">
            <el-form-item label="代码" prop="content" style="height: 100%">
              <Codemirror
                ref="cmRef"
                v-model:value="formData.content"
                :options="cmOptions"
                border
                width="100%"
                height="100%"
                @onReady="handleCmReady"
              />
            </el-form-item>
          </el-col>
        </el-row>
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
import "codemirror/mode/lua/lua.js";

import { useAppStore } from "@/store/modules/app.store";
import { DeviceEnum, LevelOptions } from "@/enums";
import Codemirror from "codemirror-editor-vue3";
import type { CmComponentRef } from "codemirror-editor-vue3";
import type { Editor, EditorConfiguration } from "codemirror";

import ModuleAPI, { ModuleForm, ModulePageQuery, ModulePageVO } from "@/api/gate/module.api";
import ConfigAPI from "@/api/gate/config.api";

defineOptions({
  name: "Module",
  inheritAttrs: false,
});

const appStore = useAppStore();

const queryFormRef = ref();
const editFormRef = ref();
const cmRef = ref<CmComponentRef>();
const cmOptions: EditorConfiguration = {
  mode: "text/x-lua",
};

const queryParams = reactive<ModulePageQuery>({
  pageNum: 1,
  pageSize: 10,
});

const pageData = ref<ModulePageVO[]>();
const total = ref(0);
const loading = ref(false);

const dialog = reactive({
  visible: false,
  title: "新增代码",
});
const drawerSize = computed(() => (appStore.device === DeviceEnum.DESKTOP ? "80%" : "90%"));

const formData = reactive<ModuleForm>({
  level: "user",
  code: "",
  content: "",
  state: "enable",
});

const rules = reactive({
  level: [{ required: true, message: "级别不能为空", trigger: "blur" }],
  code: [{ required: true, message: "编码不能为空", trigger: "blur" }],
  name: [{ required: true, message: "名称不能为空", trigger: "blur" }],
  state: [{ required: true, message: "状态不能为空", trigger: "blur" }],
});

// 选中的代码ID
const selectIds = ref<string[]>([]);
// 类型下拉数据源
const typeOptions = ref<OptionType[]>();

// 查询
async function handleQuery() {
  loading.value = true;
  handleQueryOptions();
  queryParams.pageNum = 1;
  ModuleAPI.getPage(queryParams)
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
  ConfigAPI.getConfigContent<OptionType[]>("module.type").then((data) => {
    typeOptions.value = data;
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
 * @param id 代码ID
 */
async function handleOpenDialog(id?: string) {
  dialog.visible = true;
  // 加载类型下拉数据源
  await handleQueryOptions();
  if (id) {
    dialog.title = "修改代码";
    ModuleAPI.getFormData(id).then((data) => {
      Object.assign(formData, { ...data });
    });
  } else {
    dialog.title = "新增代码";
    // 设置默认值
    formData.level = "user";
    formData.method = "*";
    formData.mode = "p";
    formData.state = "enable";
    ModuleAPI.getMaxRank()
      .then((maxRank) => {
        formData.rank = (maxRank || 0) + 1;
      })
      .catch(() => {
        formData.rank = 1; // 默认值
      });
  }
}

/**
 * 抽屉完全打开后的回调
 */
function onOpenDialog() {
  nextTick(() => {
    cmRef.value?.refresh();
  });
}

// 关闭弹窗
function handleCloseDialog() {
  dialog.visible = false;
  editFormRef.value.resetFields();
  editFormRef.value.clearValidate();
  formData.id = undefined;
}

// 提交代码表单（防抖）
const handleSubmit = useDebounceFn(() => {
  editFormRef.value.validate((valid: boolean) => {
    if (valid) {
      const id = formData.id;
      loading.value = true;
      if (id) {
        ModuleAPI.update(id, formData)
          .then(() => {
            ElMessage.success("修改代码成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      } else {
        ModuleAPI.create(formData)
          .then(() => {
            ElMessage.success("新增代码成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      }
    }
  });
}, 1000);

/**
 * 删除代码
 *
 * @param id  代码ID
 */
function handleDelete(id?: string) {
  const ids = id ? [id] : selectIds.value;
  if (!ids) {
    ElMessage.warning("请勾选删除项");
    return;
  }

  ElMessageBox.confirm("确认删除代码?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(
    function () {
      loading.value = true;
      ModuleAPI.deleteByIds(ids)
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

/**
 * 代码编辑器初始化
 *
 * @param cm CodeMirror 编辑器实例
 */
function handleCmReady(_cm: Editor) {}

onMounted(() => {
  handleQuery();
});

onUnmounted(() => {
  cmRef.value?.destroy();
});
</script>

<style lang="scss" scoped>
:deep(.CodeMirror) {
  font-size: 14px;

  .CodeMirror-line {
    line-height: 1.4em;
  }
}
</style>
