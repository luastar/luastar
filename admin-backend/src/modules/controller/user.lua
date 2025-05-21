--[===[
  用户模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local str_util = require "utils.str_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
  获取我的信息
--]]
function _M.get_my_info()
  -- 获取用户信息（拦截器写入，无需重新查询）
  local user_info = ngx.ctx.user_info
  if _.isEmpty(user_info) then
    ngx.ctx.response:writeln(res_util.failure("获取用户信息失败！"))
    return
  end
  local data = {
    id = user_info["id"],
    username = user_info["username"],
    nickname = user_info["nickname"],
    avatar = user_info["avatar"],
    roles = str_util.split(user_info["roles"], ","),
    perms = { "*:*:*" }
  }
  ngx.ctx.response:writeln(res_util.success(data))
end

--[[
  获取用户列表
--]]
function _M.get_user_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取用户列表
  local user_service = module.require("service.user")
  local call_err = ""
  local ok, count, list = xpcall(
    user_service.get_user_count_and_list,
    function(err) call_err = error_util.get_msg(err) end,
    params
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success({ total = count, list = list }))
end

--[[
  获取用户信息
--]]
function _M.get_user_info()
  -- 获取查询参数
  local id = ngx.ctx.request:get_arg("id")
  -- 从数据库获取用户信息
  local user_service = module.require("service.user")
  local call_err = ""
  local ok, user_info = xpcall(
    user_service.get_user_by_id,
    function(err) call_err = error_util.get_msg(err) end,
    id
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 转换数据类型
  user_info["rank"] = tonumber(user_info["rank"])
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(user_info))
end

--[[
  获取最大排序值
--]]
function _M.get_max_rank()
  -- 从数据库获取最大排序值
  local user_service = module.require("service.user")
  local call_err = ""
  local ok, max_rank = xpcall(
    user_service.get_max_rank,
    function(err) call_err = error_util.get_msg(err) end
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(max_rank))
end

--[[
  创建用户
--]]
function _M.create_user()
  -- 获取请求参数
  local user_info_op = ngx.ctx.user_info
  local user_info = ngx.ctx.request:get_body_json()
  -- 创建用户
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.create_user,
    function(err) call_err = error_util.get_msg(err) end,
    user_info_op, user_info
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  重置密码
--]]
function _M.reset_password()
  -- 获取请求参数
  local user_info_op = ngx.ctx.user_info
  local pass_info = ngx.ctx.request:get_body_json()
  -- 更新用户
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.update_passwd,
    function(err) call_err = error_util.get_msg(err) end,
    user_info_op, pass_info["id"], pass_info["password"]
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  更新用户
--]]
function _M.update_user()
  -- 获取请求参数
  local user_info_op = ngx.ctx.user_info
  local user_info = ngx.ctx.request:get_body_json()
  -- 更新用户
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.update_user,
    function(err) call_err = error_util.get_msg(err) end,
    user_info_op, user_info
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  删除用户
--]]
function _M.delete_user()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local params = ngx.ctx.request:get_body_json()
  -- 删除用户
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.delete_user,
    function(err) call_err = error_util.get_msg(err) end,
    user_info, params["ids"]
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

function _M.get_user_profile()
  -- 获取用户信息（拦截器写入，无需重新查询）
  local user_info = ngx.ctx.user_info
  if _.isEmpty(user_info) then
    ngx.ctx.response:writeln(res_util.failure("获取用户信息失败！"))
    return
  end
  ngx.ctx.response:writeln(res_util.success(user_info))
end

function _M.update_user_profile()
  -- 获取请求参数
  local user_info_op = ngx.ctx.user_info
  local user_info = ngx.ctx.request:get_body_json()
  -- 更新用户
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.update_user,
    function(err) call_err = error_util.get_msg(err) end,
    user_info_op, user_info
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

function _M.change_password()
  -- 获取请求参数
  local user_info_op = ngx.ctx.user_info
  local pass_info = ngx.ctx.request:get_body_json()
  -- 验证旧密码是否正确
  if user_info_op["passwd"] ~= str_util.sha256(pass_info["oldPassword"]) then
    ngx.ctx.response:writeln(res_util.failure("旧密码错误！"))
    return
  end
  -- 验证新密码与确认密码是否一致
  if pass_info["newPassword"] ~= pass_info["confirmPassword"] then
    ngx.ctx.response:writeln(res_util.failure("新密码与确认密码不一致！"))
    return
  end
  -- 更新用户密码
  local user_service = module.require("service.user")
  local call_err = ""
  local ok = xpcall(
    user_service.update_passwd,
    function(err) call_err = error_util.get_msg(err) end,
    user_info_op, user_info_op["id"], pass_info["newPassword"]
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  ngx.ctx.response:writeln(res_util.success())
end

return _M
