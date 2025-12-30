import request from "@/utils/request";

const BASE_URL = "/api/admin/user";

const UserAPI = {
  /**
   * 获取当前登录用户信息
   *
   * @returns 登录用户昵称、头像信息，包括角色和权限
   */
  getInfo() {
    return request<any, UserInfo>({
      url: `${BASE_URL}/me`,
      method: "get",
    });
  },

  /**
   * 获取用户分页列表
   *
   * @param queryParams 查询参数
   */
  getPage(queryParams: UserPageQuery) {
    return request<any, PageResult<UserPageVO[]>>({
      url: `${BASE_URL}/page`,
      method: "post",
      data: queryParams,
    });
  },

  /**
   * 获取用户表单详情
   *
   * @param id 用户ID
   * @returns 用户表单详情
   */
  getFormData(id: string) {
    return request<any, UserForm>({
      url: `${BASE_URL}/form`,
      method: "get",
      params: { id: id },
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

  /**
   * 添加用户
   *
   * @param data 用户表单数据
   */
  create(data: UserForm) {
    return request({
      url: `${BASE_URL}/create`,
      method: "post",
      data: data,
    });
  },

  /**
   * 修改用户
   *
   * @param id 用户ID
   * @param data 用户表单数据
   */
  update(id: string, data: UserForm) {
    data.id = id;
    return request({
      url: `${BASE_URL}/update`,
      method: "put",
      data: data,
    });
  },

  /**
   * 修改用户密码
   *
   * @param id 用户ID
   * @param password 新密码
   */
  resetPassword(id: string, password: string) {
    return request({
      url: `${BASE_URL}/reset-password`,
      method: "put",
      data: { id: id, password: password },
    });
  },

  /**
   * 批量删除用户，多个以英文逗号(,)分割
   *
   * @param ids 用户ID字符串，多个以英文逗号(,)分割
   */
  deleteByIds(ids: string[]) {
    return request({
      url: `${BASE_URL}/delete`,
      method: "delete",
      data: { ids: ids },
    });
  },

  /** 获取个人中心用户信息 */
  getProfile() {
    return request<any, UserProfileVO>({
      url: `${BASE_URL}/profile`,
      method: "get",
    });
  },

  /** 修改个人中心用户信息 */
  updateProfile(data: UserProfileForm) {
    return request({
      url: `${BASE_URL}/profile`,
      method: "put",
      data: data,
    });
  },

  /** 修改个人中心用户密码 */
  changePassword(data: PasswordChangeForm) {
    return request({
      url: `${BASE_URL}/change-password`,
      method: "put",
      data: data,
    });
  },
};

export default UserAPI;

/** 登录用户信息 */
export interface UserInfo {
  /** 用户ID */
  id?: string;
  /** 用户名 */
  username?: string;
  /** 昵称 */
  nickname?: string;
  /** 头像URL */
  avatar?: string;
  /** 角色 */
  roles: string[];
  /** 权限 */
  perms: string[];
}

/**
 * 用户分页查询对象
 */
export interface UserPageQuery extends PageQuery {
  /** 用户名 */
  username?: string;
  /** 昵称 */
  nickname?: string;
  /** 邮箱 */
  email?: string;
}

/** 用户表单类型 */
export interface UserForm {
  /** 用户ID */
  id?: string;
  /** 用户名 */
  username?: string;
  /** 昵称 */
  nickname?: string;
  /** 邮箱 */
  email?: string;
  /** 用户头像 */
  avatar?: string;
  /** 角色ID，逗号分隔 */
  roles?: string;
  /** 状态 */
  state?: string;
  /** 排序 */
  rank?: number;
}

/** 用户分页对象 */
export interface UserPageVO extends UserForm {
  /** 创建人 */
  createBy: string;
  /** 创建时间 */
  createAt: string;
  /** 更新人 */
  updateBy: string;
  /** 更新时间 */
  updateAt: string;
}

/** 个人中心用户信息 */
export interface UserProfileVO {
  /** 用户ID */
  id?: string;
  /** 用户名 */
  username?: string;
  /** 昵称 */
  nickname?: string;
  /** 头像URL */
  avatar?: string;
  /** 邮箱 */
  email?: string;
  /** 角色名称，多个使用英文逗号(,)分割 */
  roles?: string;
}

/** 个人中心用户信息表单 */
export interface UserProfileForm {
  /** 用户ID */
  id?: string;
  /** 用户名 */
  username?: string;
  /** 昵称 */
  nickname?: string;
  /** 头像URL */
  avatar?: string;
  /** 邮箱 */
  email?: string;
}

/** 修改密码表单 */
export interface PasswordChangeForm {
  /** 原密码 */
  oldPassword?: string;
  /** 新密码 */
  newPassword?: string;
  /** 确认新密码 */
  confirmPassword?: string;
}
