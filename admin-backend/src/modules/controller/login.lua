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
function _M.login(params)
  -- 参数校验
  local username = ngx.ctx.request:get_arg("username");
  local password = ngx.ctx.request:get_arg("password");
  if _.isEmpty(username) or _.isEmpty(password) then
    ngx.ctx.response:writeln(res_util.illegal_argument("用户名或密码不能为空"))
    return
  end
  -- 从数据库获取用户信息
  local user_service = module.require("service.user")
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
  -- 返回结果
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
function _M.refresh_token(params)
  -- 参数校验
  local refresh_token = ngx.ctx.request:get_arg("refreshToken");
  if _.isEmpty(refresh_token) then
    ngx.ctx.response:writeln(res_util.illegal_argument("refreshToken不能为空"));
    return
  end
  -- 验证token
  local jwt_config = ls_cache.get_config("jwt_config");
  local jwt_obj = jwt_util.verify(jwt_config.secret, refresh_token);
  if not jwt_obj.verified then
    ngx.ctx.response:writeln(res_util.failure("refreshToken无效"));
    return
  end
  -- 从字典里取 refreshToken
  local dict = ngx.shared.dict_ls_tokens
  local dict_refresh_token = dict:get(jwt_obj.payload.jti)
  if not dict_refresh_token then
    ngx.ctx.response:writeln(res_util.failure("refreshToken已过期"));
    return
  end
  -- 生成新的 token
  local access_token_payload = {
    jti = str_util.random_str(12),
    iss = "LuastarAdmin",
    sub = jwt_obj.payload.sub,
    exp = ngx.time() + jwt_config.access_expire,
    uid = jwt_obj.payload.uid,
  }
  local access_token = jwt_util.sign(jwt_config.secret, access_token_payload)
  -- 保存token（可改为redis）
  local ok, err = dict:set(access_token_payload.jti, access_token, jwt_config.access_expire)
  if not ok then
    logger.error("保存token失败: err = ", _.ifEmpty(err, ""))
    ngx.ctx.response:writeln(res_util.failure("保存token失败"))
    return
  end
  -- 返回结果
  local data = {
    accessToken = access_token,
    refreshToken = refresh_token,
    expires = date_util.fmt_time('%Y/%m/%d %H:%M:%S', access_token_payload.exp)
  };
  ngx.ctx.response:writeln(res_util.success(data))
end

return _M
