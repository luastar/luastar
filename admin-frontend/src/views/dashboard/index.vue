<template>
  <div class="dashboard-container">
    <!-- github 角标 -->
    <github-corner class="github-corner" />

    <el-card shadow="never" class="mt-2">
      <div class="flex flex-wrap">
        <!-- 左侧问候语区域 -->
        <div class="flex-1 flex items-start">
          <img
            class="w80px h80px rounded-full"
            :src="userStore.userInfo.avatar + '?imageView2/1/w/80/h/80'"
          />
          <div class="ml-5">
            <p>{{ greetings }}</p>
            <p class="text-sm text-gray">今日天气晴朗，气温在15℃至25℃之间，东南风。</p>
          </div>
        </div>

        <!-- 右侧图标区域 - PC端 -->
        <div class="hidden sm:block">
          <div class="flex items-end space-x-6"></div>
        </div>

        <!-- 移动端图标区域 -->
        <div class="w-full sm:hidden mt-3">
          <div class="flex justify-end space-x-4 overflow-x-auto"></div>
        </div>
      </div>
    </el-card>

    <!-- 数据统计 -->
    <el-row :gutter="10" class="mt-5">
      <!-- 请求量 -->
      <el-col :xs="24" :span="12">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span>请求数量（近1小时）</span>
            </div>
          </template>
          <ECharts :options="requestsChartOptions" height="400px" />
        </el-card>
      </el-col>
      <!-- 请求响应时间 -->
      <el-col :xs="24" :span="12">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span>请求响应时间（近1小时）</span>
            </div>
          </template>
          <ECharts :options="responseTimeChartOptions" height="400px" />
        </el-card>
      </el-col>
    </el-row>
    <el-row :gutter="10" class="mt-5">
      <!-- 请求状态码 -->
      <el-col :xs="24" :span="12">
        <el-card>
          <template #header>
            <div class="flex-x-between">
              <span>请求状态码（近1小时）</span>
            </div>
          </template>
          <ECharts :options="statusChartOptions" height="400px" />
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

import { dayjs } from "element-plus";
import StatsAPI, { StatsData } from "@/api/gate/stats.api";
import { useUserStore } from "@/store/modules/user.store";

const userStore = useUserStore();

// 当前时间（用于计算问候语）
const currentDate = new Date();

// 问候语：根据当前小时返回不同问候语
const greetings = computed(() => {
  const hours = currentDate.getHours();
  const nickname = userStore.userInfo.nickname;
  if (hours >= 6 && hours < 8) {
    return "晨起披衣出草堂，轩窗已自喜微凉🌅！";
  } else if (hours >= 8 && hours < 12) {
    return `上午好，${nickname}！`;
  } else if (hours >= 12 && hours < 18) {
    return `下午好，${nickname}！`;
  } else if (hours >= 18 && hours < 24) {
    return `晚上好，${nickname}！`;
  } else {
    return "偷偷向银河要了一把碎星，只等你闭上眼睛撒入你的梦中，晚安🌛！";
  }
});

// 请求数数图表配置
const requestsChartOptions = ref();
// 响应时间图表配置
const responseTimeChartOptions = ref();
// 状态码图表配置
const statusChartOptions = ref();

/**
 * 获取统计数据，并更新图表配置
 */
const fetchStatsData = () => {
  const startDate = Math.floor(dayjs().subtract(60, "minute").toDate().getTime() / 1000);
  const endDate = Math.floor(new Date().getTime() / 1000);
  // 获取请求数数据
  StatsAPI.getData({
    type: "requests",
    start_time: startDate,
    end_time: endDate,
  }).then((data) => {
    updateRequestsChartOptions(data);
    updateResponseTimeChartOptions(data);
  });
  // 获取状态码数据
  StatsAPI.getData({
    type: "status",
    start_time: startDate,
    end_time: endDate,
  }).then((data) => {
    updateStatusChartOptions(data);
  });
};

/**
 * 更新请求数图表的配置项
 *
 * @param data - 统计数据
 */
const updateRequestsChartOptions = (data: StatsData[]) => {
  requestsChartOptions.value = {
    tooltip: {
      trigger: "axis",
    },
    xAxis: {
      type: "category",
      data: data.map((item) => item.timestamp_str),
    },
    yAxis: {
      type: "value",
      splitLine: {
        show: true,
        lineStyle: {
          type: "dashed",
        },
      },
    },
    series: [
      {
        name: "请求数",
        type: "line",
        data: data.map((item) => item.value01 || 0),
      },
    ],
  };
};

/**
 * 更新响应时间图表的配置项
 *
 * @param data - 统计数据
 */
const updateResponseTimeChartOptions = (data: StatsData[]) => {
  responseTimeChartOptions.value = {
    tooltip: {
      trigger: "axis",
    },
    legend: {
      bottom: 0,
      data: ["最大响应时间", "平均响应时间"],
    },
    xAxis: {
      type: "category",
      data: data.map((item) => item.timestamp_str),
    },
    yAxis: {
      type: "value",
      splitLine: {
        show: true,
        lineStyle: {
          type: "dashed",
        },
      },
    },
    series: [
      {
        name: "最大响应时间",
        type: "line",
        data: data.map((item) => item.value02 || 0),
      },
      {
        name: "平均响应时间",
        type: "line",
        data: data.map((item) => item.value03 || 0),
      },
    ],
  };
};

/**
 * 更新状态图表的配置项
 *
 * @param data - 统计数据
 */
const updateStatusChartOptions = (data: StatsData[]) => {
  statusChartOptions.value = {
    tooltip: {
      trigger: "axis",
    },
    legend: {
      bottom: 0,
      data: ["2xx", "3xx", "4xx", "5xx"],
    },
    xAxis: {
      type: "category",
      data: data.map((item) => item.timestamp_str),
    },
    yAxis: {
      type: "value",
      splitLine: {
        show: true,
        lineStyle: {
          type: "dashed",
        },
      },
    },
    series: [
      {
        name: "2xx",
        type: "line",
        data: data.map((item) => item.value01 || 0),
      },
      {
        name: "3xx",
        type: "line",
        data: data.map((item) => item.value02 || 0),
      },
      {
        name: "4xx",
        type: "line",
        data: data.map((item) => item.value03 || 0),
      },
      {
        name: "5xx",
        type: "line",
        data: data.map((item) => item.value04 || 0),
      },
    ],
  };
};

// 定时刷新数据
let refreshTimer: ReturnType<typeof setInterval> | null = null;
const startRefreshTimer = () => {
  refreshTimer = setInterval(fetchStatsData, 60000);
};

onMounted(() => {
  fetchStatsData();
  startRefreshTimer();
});

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer);
  }
});
</script>

<style lang="scss" scoped>
.dashboard-container {
  position: relative;
  padding: 24px;

  .github-corner {
    position: absolute;
    top: 0;
    right: 0;
    z-index: 1;
    border: 0;
  }
}
</style>
