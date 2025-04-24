--[===[
    拦截器
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"
local jwt_util = require "utils.jwt_util"

local _M = {}

function _M.handle_before()
  logger.info("执行拦截器 handle_before 方法")
  local access_token = ngx.ctx.request:get_header("Authorization")
  if _.isEmpty(access_token) then
    ngx.ctx.response:writeln(res_util.illegal_auth("未登录"))
    return false
  end
  -- 去除 Bearer
  access_token = access_token:gsub("^%s*[Bb][Ee][Aa][Rr][Ee][Rr]%s*", "");
  -- 验证 token
  local jwt_config = ls_cache.get_config("jwt_config");
  local jwt_obj = jwt_util.verify(jwt_config.secret, access_token);
  if not jwt_obj.verified then
    ngx.ctx.response:writeln(res_util.illegal_auth("token无效"));
    return false
  end
  -- 从字典里取 token
  local dict = ngx.shared.dict_ls_tokens
  local dict_access_token = dict:get(jwt_obj.payload.jti)
  if not dict_access_token then
    ngx.ctx.response:writeln(res_util.illegal_auth("token已过期"));
    return false
  end
  return true
end

function _M.handle_after()
  logger.info("执行拦截器 handle_after 方法")
end

return _M
