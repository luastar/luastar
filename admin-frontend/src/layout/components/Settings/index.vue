<template>
  <el-drawer v-model="drawerVisible" size="300" title="项目配置" :before-close="handleCloseDrawer">
    <!-- 主题设置 -->
    <section class="config-section">
      <el-divider>主题</el-divider>

      <div class="flex-center config-item">
        <el-switch
          v-model="isDarkTheme"
          active-icon="Moon"
          inactive-icon="Sunny"
          @change="handleThemeChange"
        />
      </div>
    </section>

    <!-- 界面设置 -->
    <section class="config-section">
      <el-divider>界面设置</el-divider>

      <div class="config-item flex-x-between">
        <span class="text-xs">主题颜色</span>

        <el-color-picker
          v-model="selectedThemeColor"
          :predefine="colorPresets"
          popper-class="theme-picker-dropdown"
        />
      </div>

      <div class="config-item flex-x-between">
        <span class="text-xs">开启 Tags-View</span>
        <el-switch v-model="settingsStore.tagsView" />
      </div>

      <div class="config-item flex-x-between">
        <span class="text-xs">侧边栏 LOGO</span>
        <el-switch v-model="settingsStore.sidebarLogo" />
      </div>
    </section>

    <!-- 布局设置 -->
    <section class="config-section">
      <el-divider>导航栏设置</el-divider>
      <LayoutSelect v-model="settingsStore.layout" @update:model-value="handleLayoutChange" />
    </section>
  </el-drawer>
</template>

<script setup lang="ts">
import { LayoutMode } from "@/enums/settings/layout.enum";
import { ThemeMode } from "@/enums/settings/theme.enum";
import { useSettingsStore, usePermissionStore, useAppStore } from "@/store";

// 颜色预设
const colorPresets = [
  "#4080FF",
  "#ff4500",
  "#ff8c00",
  "#90ee90",
  "#00ced1",
  "#1e90ff",
  "#c71585",
  "rgb(255, 120, 0)",
  "hsva(120, 40, 94)",
];

const route = useRoute();
const appStore = useAppStore();
const settingsStore = useSettingsStore();
const permissionStore = usePermissionStore();

const isDarkTheme = ref<boolean>(settingsStore.theme === ThemeMode.DARK);

const selectedThemeColor = computed({
  get: () => settingsStore.themeColor,
  set: (value) => settingsStore.changeThemeColor(value),
});

const drawerVisible = computed({
  get: () => settingsStore.settingsVisible,
  set: (value) => (settingsStore.settingsVisible = value),
});

/**
 * 处理主题切换
 *
 * @param isDark 是否启用暗黑模式
 */
const handleThemeChange = (isDark: string | number | boolean) => {
  settingsStore.changeTheme(isDark ? ThemeMode.DARK : ThemeMode.LIGHT);
};

/**
 * 处理布局切换
 * @param layout - 新布局模式
 */
const handleLayoutChange = (layout: LayoutMode) => {
  settingsStore.changeLayout(layout);
  if (layout === LayoutMode.MIX && route.name) {
    const topLevelRoute = findTopLevelRoute(permissionStore.routes, route.name as string);
    if (appStore.activeTopMenuPath !== topLevelRoute.path) {
      appStore.activeTopMenu(topLevelRoute.path);
    }
  }
};

/**
 * 查找路由的顶层父路由
 *
 * @param tree 树形数据
 * @param findName 查找的名称
 */
function findTopLevelRoute(tree: any[], findName: string) {
  let parentMap: any = {};

  function buildParentMap(node: any, parent: any) {
    parentMap[node.name] = parent;

    if (node.children) {
      for (let i = 0; i < node.children.length; i++) {
        buildParentMap(node.children[i], node);
      }
    }
  }

  for (let i = 0; i < tree.length; i++) {
    buildParentMap(tree[i], null);
  }

  let currentNode = parentMap[findName];
  while (currentNode) {
    if (!parentMap[currentNode.name]) {
      return currentNode;
    }
    currentNode = parentMap[currentNode.name];
  }
  return null;
}

/**
 * 关闭抽屉前的回调
 */
const handleCloseDrawer = () => {
  settingsStore.settingsVisible = false;
};
</script>

<style lang="scss" scoped>
.config-section {
  margin-bottom: 24px;

  .config-item {
    padding: 12px 0;
    border-bottom: 1px solid var(--el-border-color-light);

    &:last-child {
      border-bottom: none;
    }
  }
}
</style>
