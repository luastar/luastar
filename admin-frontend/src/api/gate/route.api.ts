import request from "@/utils/request";

const ROUTE_BASE_URL = "/api/admin/route";

const RouteAPI = {
  /**
   * 获取路由分页列表
   *
   * @param queryParams 查询参数
   */
  getPage(queryParams: RoutePageQuery) {
    return request<any, PageResult<RoutePageVO[]>>({
      url: `${ROUTE_BASE_URL}/page`,
      method: "get",
      params: queryParams,
    });
  },

  /**
   * 获取路由表单详情
   *
   * @param id 路由ID
   * @returns 路由表单详情
   */
  getFormData(id: string) {
    return request<any, RouteForm>({
      url: `${ROUTE_BASE_URL}/form`,
      method: "get",
      params: { id: id },
    });
  },

  /**
   * 添加路由
   *
   * @param data 路由表单数据
   */
  create(data: RouteForm) {
    return request({
      url: `${ROUTE_BASE_URL}/create`,
      method: "post",
      data: data,
    });
  },

  /**
   * 修改路由
   *
   * @param id 路由ID
   * @param data 路由表单数据
   */
  update(id: string, data: RouteForm) {
    data.id = id;
    return request({
      url: `${ROUTE_BASE_URL}/update`,
      method: "put",
      data: data,
    });
  },

  /**
   * 批量删除路由
   *
   * @param ids 路由ID数组
   */
  deleteByIds(ids: string[]) {
    return request({
      url: `${ROUTE_BASE_URL}/delete`,
      method: "delete",
      data: { ids: ids },
    });
  },
};

export default RouteAPI;

/**
 * 路由分页查询对象
 */
export interface RoutePageQuery extends PageQuery {
  /** 级别 */
  level?: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code?: string;
  /** 名称 */
  name?: string;
  /** 路径 */
  path?: string;
}

/** 路由分页对象 */
export interface RoutePageVO {
  /** ID */
  id: string;
  /** 级别 */
  level?: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code?: string;
  /** 名称 */
  name?: string;
  /** 路径 */
  path?: string;
  /** 请求方法 */
  method?: string;
  /** 匹配模式 */
  mode?: string;
  /** 代码模块 */
  mcode?: string;
  /** 代码函数 */
  mfunc?: string;
  /** 参数 */
  params?: string;
  /** 状态 */
  state?: string;
  /** 排序 */
  rank?: number;
}

/** 路由表单类型 */
export interface RouteForm {
  /** ID */
  id?: string;
  /** 级别 */
  level: string;
  /** 类型 */
  type?: string;
  /** 编码 */
  code: string;
  /** 名称 */
  name?: string;
  /** 路径 */
  path: string;
  /** 请求方法 */
  method?: string;
  /** 匹配模式 */
  mode?: string;
  /** 代码模块 */
  mcode?: string;
  /** 代码函数 */
  mfunc?: string;
  /** 参数 */
  params?: string;
  /** 状态 */
  state: string;
  /** 排序 */
  rank?: number;
}
