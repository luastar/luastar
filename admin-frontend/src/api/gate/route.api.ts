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
   * @param userId 路由ID
   * @returns 路由表单详情
   */
  getFormData(userId: string) {
    return request<any, RouteForm>({
      url: `${ROUTE_BASE_URL}/${userId}/form`,
      method: "get",
    });
  },

  /**
   * 添加路由
   *
   * @param data 路由表单数据
   */
  create(data: RouteForm) {
    return request({
      url: `${ROUTE_BASE_URL}`,
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
    return request({
      url: `${ROUTE_BASE_URL}/${id}`,
      method: "put",
      data: data,
    });
  },

  /**
   * 修改路由密码
   *
   * @param id 路由ID
   * @param password 新密码
   */
  resetPassword(id: string, password: string) {
    return request({
      url: `${ROUTE_BASE_URL}/${id}/password/reset`,
      method: "put",
      params: { password: password },
    });
  },

  /**
   * 批量删除路由，多个以英文逗号(,)分割
   *
   * @param ids 路由ID字符串，多个以英文逗号(,)分割
   */
  deleteByIds(ids: string) {
    return request({
      url: `${ROUTE_BASE_URL}/${ids}`,
      method: "delete",
    });
  },

  /** 下载路由导入模板 */
  downloadTemplate() {
    return request({
      url: `${ROUTE_BASE_URL}/template`,
      method: "get",
      responseType: "blob",
    });
  },

  /**
   * 导出路由
   *
   * @param queryParams 查询参数
   */
  export(queryParams: RoutePageQuery) {
    return request({
      url: `${ROUTE_BASE_URL}/export`,
      method: "get",
      params: queryParams,
      responseType: "blob",
    });
  },

  /**
   *  获取路由下拉列表
   */
  getOptions() {
    return request<any, OptionType[]>({
      url: `${ROUTE_BASE_URL}/options`,
      method: "get",
    });
  },
};

export default RouteAPI;

/**
 * 路由分页查询对象
 */
export interface RoutePageQuery extends PageQuery {
  /** 搜索关键字 */
  keywords?: string;

  /** 路由状态 */
  status?: number;

  /** 部门ID */
  deptId?: string;

  /** 开始时间 */
  createTime?: [string, string];
}

/** 路由分页对象 */
export interface RoutePageVO {
  /** 路由ID */
  id: string;
  /** 路由头像URL */
  avatar?: string;
  /** 创建时间 */
  createTime?: Date;
  /** 部门名称 */
  deptName?: string;
  /** 路由邮箱 */
  email?: string;
  /** 性别 */
  gender?: number;
  /** 手机号 */
  mobile?: string;
  /** 路由昵称 */
  nickname?: string;
  /** 角色名称，多个使用英文逗号(,)分割 */
  roleNames?: string;
  /** 路由状态(1:启用;0:禁用) */
  status?: number;
  /** 路由名 */
  username?: string;
}

/** 路由表单类型 */
export interface RouteForm {
  /** 路由ID */
  id?: string;
  /** 路由头像 */
  avatar?: string;
  /** 部门ID */
  deptId?: string;
  /** 邮箱 */
  email?: string;
  /** 性别 */
  gender?: number;
  /** 手机号 */
  mobile?: string;
  /** 昵称 */
  nickname?: string;
  /** 角色ID集合 */
  roleIds?: number[];
  /** 路由状态(1:正常;0:禁用) */
  status?: number;
  /** 路由名 */
  username?: string;
}
