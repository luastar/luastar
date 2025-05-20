import request from "@/utils/request";

const BASE_URL = "/api/admin/module";

const ModuleAPI = {
  /** 获取代码列表 */
  getPage(queryParams: ModulePageQuery) {
    return request<any, PageResult<ModulePageVO[]>>({
      url: `${BASE_URL}/page`,
      method: "post",
      data: queryParams,
    });
  },

  /** 获取代码详情 */
  getFormData(id: string) {
    return request<any, ModuleForm>({
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

  /** 创建代码 */
  create(data: ModuleForm) {
    return request<any, string>({
      url: `${BASE_URL}/create`,
      method: "post",
      data,
    });
  },

  /** 更新代码 */
  update(id: string, data: ModuleForm) {
    data.id = id;
    return request({
      url: `${BASE_URL}/update`,
      method: "put",
      data,
    });
  },

  /** 批量删除代码 */
  deleteByIds(ids: string[]) {
    return request({
      url: `${BASE_URL}/delete`,
      method: "delete",
      data: { ids },
    });
  },
};

export default ModuleAPI;

/** 代码分页查询参数 */
export interface ModulePageQuery extends PageQuery {
  /** 级别 */
  level?: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code?: string;
  /** 名称 */
  name?: string;
}

/** 代码表单对象 */
export interface ModuleForm {
  /** 主键 */
  id?: string;
  /** 级别 */
  level: string;
  /** 类型 */
  type: string;
  /** 编码 */
  code: string;
  /** 名称 */
  name: string;
  /** 描述 */
  desc: string;
  /** 内容 */
  content: string;
  /** 状态 */
  state: string;
  /** 排序 */
  rank?: number;
}

/** 代码分页对象 */
export interface ModulePageVO extends ModuleForm {
  /** 创建人 */
  createBy: string;
  /** 创建时间 */
  createAt: string;
  /** 更新人 */
  updateBy: string;
  /** 更新时间 */
  updateAt: string;
}
