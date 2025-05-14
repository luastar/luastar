/**
 * 响应码枚举
 */
export const enum ResultEnum {
  /**
   * 访问令牌无效或过期
   */
  ACCESS_TOKEN_INVALID = "401",

  /**
   * 刷新令牌无效或过期
   */
  REFRESH_TOKEN_INVALID = "402",
}
