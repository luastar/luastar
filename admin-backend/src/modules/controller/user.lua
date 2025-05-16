--[===[
  用户模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local error_util = require "utils.error_util"

local _M = {}

function _M.get_user_info(params)
  -- 获取用户信息（拦截器写入，无需重新查询）
  local user_info = ngx.ctx.user_info
  if _.isEmpty(user_info) then
    ngx.ctx.response:writeln(res_util.failure("获取用户信息失败！"))
    return
  end
  -- 获取用户角色信息
  local user_service = module.require("service.user")
  local call_err = ""
  local ok, user_role = xpcall(user_service.get_user_role, function(err)
    call_err = error_util.get_msg(err)
  end, user_info.id)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  local data = {
    userId = user_info.id,
    username = user_info.username,
    nickname = user_info.nickname,
    avatar = user_info.avatar,
    roles = user_role,
    perms = { "*:*:*" }
  }
  ngx.ctx.response:writeln(res_util.success(data))
end

function _M.get_user_profile(params)
  -- 获取用户信息（拦截器写入，无需重新查询）
  local user_info = ngx.ctx.user_info
  if _.isEmpty(user_info) then
    ngx.ctx.response:writeln(res_util.failure("获取用户信息失败！"))
    return
  end
  local data = {
    id = user_info.id,
    username = user_info.username,
    nickname = user_info.nickname,
    avatar = user_info.avatar,
    gender = 1,
    mobile = "",
    email = user_info.email,
    createTime = user_info.create_at
  }
  ngx.ctx.response:writeln(res_util.success(data))
end

return _M
