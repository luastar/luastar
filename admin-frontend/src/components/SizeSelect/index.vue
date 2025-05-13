<template>
  <el-tooltip content="布局大小" effect="dark" placement="bottom">
    <el-dropdown trigger="click" @command="handleSizeChange">
      <div>
        <div class="i-svg:size" />
      </div>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item
            v-for="item of sizeOptions"
            :key="item.value"
            :disabled="appStore.size == item.value"
            :command="item.value"
          >
            {{ item.label }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
  </el-tooltip>
</template>

<script setup lang="ts">
import { ComponentSize } from "@/enums/settings/layout.enum";
import { useAppStore } from "@/store/modules/app.store";

const sizeOptions = computed(() => {
  return [
    { label: "默认", value: ComponentSize.DEFAULT },
    { label: "大型", value: ComponentSize.LARGE },
    { label: "小型", value: ComponentSize.SMALL },
  ];
});

const appStore = useAppStore();
function handleSizeChange(size: string) {
  appStore.changeSize(size);
  ElMessage.success("切换布局大小成功");
}
</script>
