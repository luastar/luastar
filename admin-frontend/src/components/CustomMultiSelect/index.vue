<template>
  <el-select
    v-model="localValue"
    v-bind="$attrs"
    multiple
    @change="handleChange"
    @blur="$emit('blur', $event)"
    @focus="$emit('focus', $event)"
  >
    <slot />
  </el-select>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";

defineOptions({
  name: "CustomMultiSelect",
  inheritAttrs: false,
});

const props = defineProps({
  modelValue: {
    type: String,
    default: "",
  },
});

const emit = defineEmits(["update:modelValue", "focus", "blur"]);

// 本地值，用于在组件内部管理数组格式
const localValue = ref<string[]>([]);

// 初始化本地值，将逗号分隔的字符串转换为数组
watch(
  () => props.modelValue,
  (newVal) => {
    localValue.value = newVal ? newVal.split(",") : [];
  },
  { immediate: true }
);

// 处理选择变化，将数组转回逗号分隔的字符串
const handleChange = (value: []) => {
  emit("update:modelValue", value.join(","));
};
</script>
