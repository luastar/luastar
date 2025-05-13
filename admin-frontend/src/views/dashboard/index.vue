<template>
  <div class="p-5">
    <el-card shadow="never">
      <el-row justify="space-between">
        <el-col :span="18" :xs="24">
          <div class="flex h-full items-center">
            <img
              class="w-20 h-20 mr-5 rounded-full"
              :src="userStore.userInfo.avatar + '?imageView2/1/w/80/h/80'"
            />
            <div>
              <p>{{ greetings }}</p>
              <p class="text-sm text-gray">今日天气晴朗，气温在15℃至25℃之间，东南风。</p>
            </div>
          </div>
        </el-col>

        <el-col :span="6" :xs="24">
          <el-row class="h-80px flex-y-center" :gutter="10">
            <el-col :span="10">
              <div class="font-bold color-#ff9a2e text-sm flex-y-center">
                <el-icon class="mr-2px"><Folder /></el-icon>
                仓库
              </div>
              <div class="mt-3">
                <el-link href="https://gitee.com/youlaiorg/vue3-element-admin" target="_blank">
                  <div class="i-svg:gitee text-lg color-#F76560" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://github.com/youlaitech/vue3-element-admin" target="_blank">
                  <div class="i-svg:github text-lg color-#4080FF" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://gitcode.com/youlai/vue3-element-admin" target="_blank">
                  <div class="i-svg:gitcode text-lg color-#FF9A2E" />
                </el-link>
              </div>
            </el-col>

            <el-col :span="10">
              <div class="font-bold color-#4080ff text-sm flex-y-center">
                <el-icon class="mr-2px"><Document /></el-icon>
                文档
              </div>
              <div class="mt-3">
                <el-link href="https://juejin.cn/post/7228990409909108793" target="_blank">
                  <div class="i-svg:juejin text-lg" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link
                  href="https://youlai.blog.csdn.net/article/details/130191394"
                  target="_blank"
                >
                  <div class="i-svg:csdn text-lg" />
                </el-link>
                <el-divider direction="vertical" />
                <el-link href="https://www.cnblogs.com/haoxianrui/p/17331952.html" target="_blank">
                  <div class="i-svg:cnblogs text-lg" />
                </el-link>
              </div>
            </el-col>

            <el-col :span="4">
              <div class="font-bold color-#f76560 text-sm flex-y-center">
                <el-icon class="mr-2px"><VideoCamera /></el-icon>
                视频
              </div>
              <div class="mt-3">
                <el-link href="https://www.bilibili.com/video/BV1eFUuYyEFj" target="_blank">
                  <div class="i-svg:bilibili text-lg" />
                </el-link>
              </div>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
    </el-card>

    <el-row class="mt-3">
      <el-col>
        <el-card>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="项目名称">
              <span class="font-bold">vue3-element-template</span>
            </el-descriptions-item>
            <el-descriptions-item label="项目描述">
              🚀 基于vue3-element-admin核心的RBAC权限开发模板，精简国际化等非核心功能。
            </el-descriptions-item>
            <el-descriptions-item label="项目源码">
              <el-link
                href="https://gitee.com/youlaiorg/vue3-element-template"
                target="_blank"
                type="primary"
              >
                Gitee
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
            <el-descriptions-item label="后端源码">
              <el-link
                href="https://gitee.com/youlaiorg/youlai-nest"
                target="_blank"
                type="primary"
              >
                Node 后端（youlai-nest）
                <el-icon><Link /></el-icon>
              </el-link>

              <el-link
                href="https://gitee.com/youlaiorg/youlai-boot"
                target="_blank"
                type="success"
                class="ml-2"
              >
                Java 后端（youlai-boot）
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
            <el-descriptions-item label="项目文档">
              <el-link
                href="https://juejin.cn/post/7228990409909108793"
                target="_blank"
                type="primary"
              >
                稀土掘金
                <el-icon><Link /></el-icon>
              </el-link>
              <el-link
                href="https://youlai.blog.csdn.net/article/details/130191394"
                target="_blank"
                type="success"
                class="ml-2"
              >
                CSDN
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
            <el-descriptions-item label="项目作者">
              <el-link href="https://gitee.com/youlaiorg" target="_blank" type="primary">
                有来开源组织
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>

    <el-row class="mt-3">
      <el-col>
        <el-card>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="项目名称">
              <span class="font-bold">vue3-element-admin</span>
            </el-descriptions-item>
            <el-descriptions-item label="项目描述">
              🔥Vue3 + Vite6 + TypeScript + Element-Plus 构建企业级中后台全栈解决方案。
            </el-descriptions-item>
            <el-descriptions-item label="项目源码">
              <el-link
                href="https://gitee.com/youlaiorg/vue3-element-admin"
                target="_blank"
                type="primary"
              >
                Gitee
                <el-icon><Link /></el-icon>
              </el-link>

              <el-link
                href="https://gitcode.com/youlai/vue3-element-admin"
                target="_blank"
                type="success"
                class="ml-2"
              >
                GitCode
                <el-icon><Link /></el-icon>
              </el-link>

              <el-link
                href="https://github.com/youlaitech/vue3-element-admin"
                target="_blank"
                type="warning"
                class="ml-2"
              >
                Github
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
            <el-descriptions-item label="项目作者">
              <el-link href="https://gitee.com/youlaiorg" target="_blank" type="primary">
                有来开源组织
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>

    <el-row class="mt-3">
      <el-col>
        <el-card>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="项目名称">
              <span class="font-bold">vue3-element-admin-thin</span>
            </el-descriptions-item>
            <el-descriptions-item label="项目描述">
              🌈 vue3-element-admin 的精简版，仅包含主体功能（登录和菜单路由)。
            </el-descriptions-item>
            <el-descriptions-item label="项目源码">
              <el-link
                href="https://gitee.com/cshaptx4869/vue3-element-admin-thin"
                target="_blank"
                type="primary"
              >
                Gitee
                <el-icon><Link /></el-icon>
              </el-link>

              <el-link
                href="https://github.com/youlaitech/vue3-element-admin-thin"
                target="_blank"
                type="warning"
                class="ml-2"
              >
                Github
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
            <el-descriptions-item label="项目作者">
              <el-link href="https://github.com/cshaptx4869" target="_blank" type="primary">
                cshaptx4869
                <el-icon><Link /></el-icon>
              </el-link>
            </el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
defineOptions({
  name: "Dashboard",
  inheritAttrs: false,
});
import { useUserStore } from "@/store/modules/user.store";

const userStore = useUserStore();
const date: Date = new Date();
const greetings = computed(() => {
  const hours = date.getHours();
  if (hours >= 6 && hours < 8) {
    return "晨起披衣出草堂，轩窗已自喜微凉🌅！";
  } else if (hours >= 8 && hours < 12) {
    return "上午好，" + userStore.userInfo.nickname + "！";
  } else if (hours >= 12 && hours < 18) {
    return "下午好，" + userStore.userInfo.nickname + "！";
  } else if (hours >= 18 && hours < 24) {
    return "晚上好，" + userStore.userInfo.nickname + "！";
  } else {
    return "偷偷向银河要了一把碎星，只等你闭上眼睛撒入你的梦中，晚安🌛！";
  }
});
</script>

<style lang="scss" scoped></style>
