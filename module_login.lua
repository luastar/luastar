--[===[
    登录模块
--]===]
local ngx = require "ngx"
local str_util = require "utils.str_util"
local res_util = require "utils.res_util"
local jwt_util = require "utils.jwt_util"
local date_util = require "utils.date_util"
local module = require "core.module"

local _M = {}

--[[
 登录
--]]
function _M.login()
  -- 参数校验
  local username = ngx.ctx.request:get_arg("username");
  local password = ngx.ctx.request:get_arg("password");
  if _.isEmpty(username) or _.isEmpty(password) then
    ngx.ctx.response:writeln(res_util.illegal_argument("用户名或密码不能为空"))
    return
  end
  -- 从数据库获取用户信息
  local user_service = module.require("system.service.user")
  local ok, user_info = xpcall(user_service.get_user_info, function(err)
    ngx.ctx.response:writeln(res_util.failure(err))
  end, username);
  if not ok then
    return
  end
  -- 验证密码
  if user_info.passwd ~= str_util.sha256(password) then
    ngx.ctx.response:writeln(res_util.failure("用户名或密码错误"))
    return
  end
  -- 查询用户角色和权限
  local ok, roles, permissions = xpcall(user_service.get_user_role_permission, function(err)
    ngx.ctx.response:writeln(res_util.failure(err))
  end, user_info.id)
  if not ok then
    return
  end
  -- 生成 token
  local jwt_config = ls_cache.get_config("jwt_config")
  local access_token_payload = {
    jti = str_util.random_str(12),
    iss = "LuastarAdmin",
    sub = username,
    exp = ngx.time() + jwt_config.access_expire,
    uid = user_info.id,
  }
  local refresh_token_payload = {
    jti = str_util.random_str(12),
    iss = "LuastarAdmin",
    sub = username,
    exp = ngx.time() + jwt_config.refresh_expire,
    uid = user_info.id,
  }
  local access_token = jwt_util.sign(jwt_config.secret, access_token_payload)
  local refresh_token = jwt_util.sign(jwt_config.secret, refresh_token_payload)
  -- 保存token（可改为redis）
  local dict = ngx.shared.dict_ls_tokens
  local ok1, err1 = dict:set(access_token_payload.jti, access_token, jwt_config.access_expire)
  local ok2, err2 = dict:set(refresh_token_payload.jti, refresh_token, jwt_config.refresh_expire)
  if not ok1 or not ok2 then
    logger.error("保存token失败: err1 = ", _.ifEmpty(err1, ""), ", err2 = ", _.ifEmpty(err2, ""))
    ngx.ctx.response:writeln(res_util.failure("保存token失败"))
    return
  end
  local data = {
    username = user_info.username,
    nickname = user_info.nickname,
    avatar = user_info.avatar,
    roles = roles,
    permissions = permissions,
    accessToken = access_token,
    refreshToken = refresh_token,
    expires = date_util.fmt_time('%Y/%m/%d %H:%M:%S', access_token_payload.exp)
  };
  ngx.ctx.response:writeln(res_util.success(data))
end

--[[
 刷新 token
--]]
function _M.refresh_token(request, response)
  local refresh_token = request:get_arg("refreshToken");
  if refresh_token then
    local data = {
      accessToken = "eyJhbGciOiJIUzUxMiJ9.newAdmin",
      refreshToken = "eyJhbGciOiJIUzUxMiJ9.newAdminRefresh",
      expires = "2030/10/30 23:59:59"
    };
    response:set_content_type_json()
    response:writeln(res_util.success(data))
  else
    response:set_content_type_json()
    response:writeln(res_util.failure())
  end
end

return _M
