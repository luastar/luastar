// 核心枚举定义
export enum MenuTypeEnum {
  CATALOG = 2, // 目录
  MENU = 1, // 菜单
  BUTTON = 3, // 按钮
  EXTLINK = 4, // 外链
}

// 类型标签映射配置
export const MenuTypeConfig = {
  [MenuTypeEnum.CATALOG]: {
    label: "目录",
    type: "warning" as const,
    icon: "folder-opened",
    value: 2,
  },
  [MenuTypeEnum.MENU]: {
    label: "菜单",
    type: "success" as const,
    icon: "menu",
    value: 1,
  },
  [MenuTypeEnum.BUTTON]: {
    label: "按钮",
    type: "danger" as const,
    icon: "mouse",
    value: 3,
  },
  [MenuTypeEnum.EXTLINK]: {
    label: "外链",
    type: "info" as const,
    icon: "link",
    value: 4,
  },
} as const;
