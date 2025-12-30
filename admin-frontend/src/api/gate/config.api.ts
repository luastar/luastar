import request from "@/utils/request";

const BASE_URL = "/api/admin/config";

const ConfigAPI = {
  /** 获取配置内容 */
  getConfigContent<T>(code: string) {
    return request<any, T>({
      url: `${BASE_URL}/content`,
      method: "get",
      params: { code },
    });
  },

  /** 获取配置列表 */
  getPage(queryParams: ConfigPageQuery) {
    return request<any, PageResult<ConfigPageVO[]>>({
      url: `${BASE_URL}/page`,
      method: "post",
      data: queryParams,
    });
  },

  /** 获取配置详情 */
  getFormData(id: string) {
    return request<any, ConfigForm>({
      url: `${BASE_URL}/form`,
      method: "get",
      params: { id },
    });
  },

  /**
   * 获取最大排序值
   */
  getMaxRank() {
    return request<any, number>({
      url: `${BASE_URL}/get-max-rank`,
      method: "get",
    });
  },

  /** 创建配置 */
  create(data: ConfigForm) {
    return request<any, string>({
      url: `${BASE_URL}/create`,
      method: "post",
      data,
    });
  },

  /** 更新配置 */
  update(id: string, data: ConfigForm) {
    data.id = id;
    return request({
      url: `${BASE_URL}/update`,
      method: "put",
      data,
    });
  },

  /** 批量删除配置 */
  deleteByIds(ids: string[]) {
    return request({
      url: `${BASE_URL}/delete`,
      method: "delete",
      data: { ids },
    });
  },
};

export default ConfigAPI;

/** 配置值类型枚举 */
export enum ConfigVType {
  STRING = "string",
  NUMBER = "number",
  BOOLEAN = "boolean",
  OBJECT = "object",
  ARRAY = "array",
}

/** 配置分页查询参数 */
export interface ConfigPageQuery extends PageQuery {
  /** 级别 */
  level?: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code?: string;
  /** 名称 */
  name?: string;
}

/** 配置表单对象 */
export interface ConfigForm {
  /** 主键 */
  id?: string;
  /** 级别 */
  level: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code: string;
  /** 名称 */
  name: string;
  /** 值类型 */
  vtype: string;
  /** 值内容 */
  vcontent: string;
  /** 状态 */
  state: string;
  /** 排序 */
  rank?: number;
}

/** 配置分页对象 */
export interface ConfigPageVO extends ConfigForm {
  /** 创建人 */
  createBy: string;
  /** 创建时间 */
  createAt: string;
  /** 更新人 */
  updateBy: string;
  /** 更新时间 */
  updateAt: string;
}
