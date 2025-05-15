--[===[
    拦截器
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local jwt_util = require "utils.jwt_util"
local error_util = require "utils.error_util"

local _M = {}

function _M.handle_before()
  logger.info("执行拦截器 handle_before 方法")
  local access_token = ngx.ctx.request:get_header("Authorization")
  if _.isEmpty(access_token) then
    ngx.ctx.response:writeln(res_util.invalid_access_token("token无效！"))
    return false
  end
  -- 去除 Bearer
  access_token = access_token:gsub("^%s*[Bb][Ee][Aa][Rr][Ee][Rr]%s*", "");
  -- 验证 token
  local jwt_config = ls_cache.get_config("jwt_config");
  local jwt_obj = jwt_util.verify(jwt_config.secret, access_token);
  if not jwt_obj.verified then
    ngx.ctx.response:writeln(res_util.invalid_access_token("token无效！"));
    return false
  end
  -- 从字典里取 token
  local dict = ngx.shared.dict_ls_tokens
  local dict_access_token = dict:get("access:" .. jwt_obj.payload.jti)
  if not dict_access_token then
    ngx.ctx.response:writeln(res_util.invalid_access_token("token已过期！"));
    return false
  end
  -- 获取用户信息
  local uid = jwt_obj.payload.uid
  if _.isEmpty(uid) then
    ngx.ctx.response:writeln(res_util.invalid_access_token("获取用户信息失败！"));
    return false
  end
  local user_service = module.require("service.user")
  local call_err = ""
  local ok, user_info = xpcall(user_service.get_user_info_by_id, function(err)
    call_err = error_util.get_msg(err)
  end, uid);
  if not ok then
    ngx.ctx.response:writeln(res_util.invalid_access_token("获取用户信息失败: " .. call_err));
    return false
  end
  -- 存放到上下文
  ngx.ctx.token_jti = jwt_obj.payload.jti
  ngx.ctx.user_info = user_info
  return true
end

function _M.handle_after()
  logger.info("执行拦截器 handle_after 方法")
end

return _M
