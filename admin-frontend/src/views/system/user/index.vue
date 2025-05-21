<!-- 用户管理 -->
<template>
  <div class="app-container">
    <!-- 用户列表 -->
    <!-- 搜索区域 -->
    <div class="search-container">
      <el-form ref="queryFormRef" :model="queryParams" :inline="true" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="queryParams.username"
            placeholder="请输入用户名"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>

        <el-form-item label="昵称" prop="nickname">
          <el-input
            v-model="queryParams.nickname"
            placeholder="请输入昵称"
            clearable
            @keyup.enter="handleQuery"
          />
        </el-form-item>

        <el-form-item label="邮箱" prop="email">
          <el-input
            v-model="queryParams.email"
            placeholder="请输入邮箱"
            clearable
            @keyup.enter="handleQuery"
          />
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
        <el-table-column label="用户名" prop="username" />
        <el-table-column label="昵称" width="150" prop="nickname" />
        <el-table-column label="邮箱" prop="email" width="160" />
        <el-table-column label="状态" align="center" prop="state" width="80">
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
              icon="RefreshLeft"
              size="small"
              link
              @click="hancleResetPassword(scope.row)"
            >
              重置密码
            </el-button>
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

    <!-- 用户表单 -->
    <el-drawer
      v-model="dialog.visible"
      :title="dialog.title"
      append-to-body
      :size="drawerSize"
      @close="handleCloseDialog"
    >
      <el-form ref="editFormRef" :model="formData" :rules="rules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="formData.username"
            :readonly="!!formData.id"
            placeholder="请输入用户名"
          />
        </el-form-item>

        <el-form-item label="用户昵称" prop="nickname">
          <el-input v-model="formData.nickname" placeholder="请输入用户昵称" />
        </el-form-item>

        <el-form-item label="邮箱" prop="email">
          <el-input v-model="formData.email" placeholder="请输入邮箱" maxlength="50" />
        </el-form-item>

        <el-form-item v-if="formData.id === undefined" label="密码" prop="passwd">
          <el-text class="mx-1" type="primary">默认密码为：LuastarAdmin123456</el-text>
        </el-form-item>

        <el-form-item label="角色" prop="roles">
          <CustomMultiSelect v-model="formData.roles" multiple placeholder="请选择角色">
            <el-option
              v-for="item in roleOptions"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </CustomMultiSelect>
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
          <el-input-number v-model="formData.rank" label="请输入排序" />
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
import CustomMultiSelect from "@/components/CustomMultiSelect/index.vue";
import UserAPI, { UserForm, UserPageQuery, UserPageVO } from "@/api/system/user.api";

import { useAppStore } from "@/store/modules/app.store";
import { DeviceEnum } from "@/enums/settings/device.enum";

defineOptions({
  name: "User",
  inheritAttrs: false,
});

const appStore = useAppStore();

const queryFormRef = ref();
const editFormRef = ref();

const queryParams = reactive<UserPageQuery>({
  pageNum: 1,
  pageSize: 10,
});

const pageData = ref<UserPageVO[]>();
const total = ref(0);
const loading = ref(false);

const dialog = reactive({
  visible: false,
  title: "新增用户",
});
const drawerSize = computed(() => (appStore.device === DeviceEnum.DESKTOP ? "600px" : "90%"));

const formData = reactive<UserForm>({});

const rules = reactive({
  username: [{ required: true, message: "用户名不能为空", trigger: "blur" }],
  nickname: [{ required: true, message: "用户昵称不能为空", trigger: "blur" }],
  email: [
    { required: true, message: "邮箱不能为空", trigger: "blur" },
    {
      pattern: /\w[-\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\.)+[A-Za-z]{2,14}/,
      message: "请输入正确的邮箱地址",
      trigger: "blur",
    },
  ],
  roles: [{ required: true, message: "用户角色不能为空", trigger: "blur" }],
});

// 选中的用户ID
const selectIds = ref<string[]>([]);
// 角色下拉数据源
const roleOptions: OptionType[] = [
  { label: "管理员", value: "admin" },
  { label: "普通用户", value: "user" },
];

// 查询
async function handleQuery() {
  loading.value = true;
  queryParams.pageNum = 1;
  UserAPI.getPage(queryParams)
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

// 重置密码
function hancleResetPassword(row: UserPageVO) {
  ElMessageBox.prompt("请输入用户【" + row.username + "】的新密码", "重置密码", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
  }).then(
    ({ value }) => {
      if (!value || value.length < 6) {
        ElMessage.warning("密码至少需要6位字符，请重新输入");
        return false;
      }
      UserAPI.resetPassword(row.id || "", value).then(() => {
        ElMessage.success("密码重置成功，新密码是：" + value);
      });
    },
    () => {
      ElMessage.info("已取消重置密码");
    }
  );
}

/**
 * 打开弹窗
 *
 * @param id 用户ID
 */
async function handleOpenDialog(id?: string) {
  dialog.visible = true;
  if (id) {
    dialog.title = "修改用户";
    UserAPI.getFormData(id).then((data) => {
      Object.assign(formData, { ...data });
    });
  } else {
    dialog.title = "新增用户";
    formData.roles = "common";
    formData.state = "enable";
    UserAPI.getMaxRank()
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

// 提交用户表单（防抖）
const handleSubmit = useDebounceFn(() => {
  editFormRef.value.validate((valid: boolean) => {
    if (valid) {
      const id = formData.id;
      loading.value = true;
      if (id) {
        UserAPI.update(id, formData)
          .then(() => {
            ElMessage.success("修改用户成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      } else {
        UserAPI.create(formData)
          .then(() => {
            ElMessage.success("新增用户成功");
            handleCloseDialog();
            handleResetQuery();
          })
          .finally(() => (loading.value = false));
      }
    }
  });
}, 1000);

/**
 * 删除用户
 *
 * @param id  用户ID
 */
function handleDelete(id?: string) {
  const ids = id ? [id] : selectIds.value;
  if (!ids) {
    ElMessage.warning("请勾选删除项");
    return;
  }

  ElMessageBox.confirm("确认删除用户?", "警告", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  }).then(
    function () {
      loading.value = true;
      UserAPI.deleteByIds(ids)
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
