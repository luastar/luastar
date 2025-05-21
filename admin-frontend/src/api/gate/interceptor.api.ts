import request from "@/utils/request";

const BASE_URL = "/api/admin/interceptor";

const InterceptorAPI = {
  /** 获取拦截器列表 */
  getPage(queryParams: InterceptorPageQuery) {
    return request<any, PageResult<InterceptorPageVO[]>>({
      url: `${BASE_URL}/page`,
      method: "post",
      data: queryParams,
    });
  },

  /** 获取拦截器详情 */
  getFormData(id: string) {
    return request<any, InterceptorForm>({
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

  /** 创建拦截器 */
  create(data: InterceptorForm) {
    return request<any, string>({
      url: `${BASE_URL}/create`,
      method: "post",
      data,
    });
  },

  /** 更新拦截器 */
  update(id: string, data: InterceptorForm) {
    data.id = id;
    return request({
      url: `${BASE_URL}/update`,
      method: "put",
      data,
    });
  },

  /** 批量删除拦截器 */
  deleteByIds(ids: string[]) {
    return request({
      url: `${BASE_URL}/delete`,
      method: "delete",
      data: { ids },
    });
  },
};

export default InterceptorAPI;

/** 拦截器分页查询参数 */
export interface InterceptorPageQuery extends PageQuery {
  /** 级别 */
  level?: string;
  /** 编码 */
  code?: string;
  /** 名称 */
  name?: string;
}

/** 拦截器表单对象 */
export interface InterceptorForm {
  /** 主键 */
  id?: string;
  /** 级别 */
  level: string;
  /** 编码 */
  code: string;
  /** 名称 */
  name?: string;
  /** 拦截路由 */
  routes: string;
  /** 排除路由 */
  routes_exclude?: string;
  /** 代码模块 */
  mcode: string;
  /** 执行前置函数 */
  mfunc_before: string;
  /** 执行后置函数 */
  mfunc_after: string;
  /** 参数 */
  params?: string;
  /** 状态 */
  state: string;
  /** 排序 */
  rank?: number;
}

/** 拦截器分页对象 */
export interface InterceptorPageVO extends InterceptorForm {
  /** 创建人 */
  createBy: string;
  /** 创建时间 */
  createAt: string;
  /** 更新人 */
  updateBy: string;
  /** 更新时间 */
  updateAt: string;
}
