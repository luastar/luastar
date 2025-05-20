--[===[
  拦截器管理模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
  获取拦截器列表
--]]
function _M.get_interceptor_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取拦截器列表
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok, count, list = xpcall(function()
    return interceptor_service.get_interceptor_count_and_list(params)
  end, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success({ total = count, list = list }))
end

--[[
  获取拦截器信息
--]]
function _M.get_interceptor_info()
  -- 获取查询参数
  local id = ngx.ctx.request:get_arg("id")
  -- 从数据库获取拦截器信息
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok, interceptor_info = xpcall(interceptor_service.get_interceptor_by_id, function(err)
    call_err = error_util.get_msg(err)
  end, id)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 转换数据类型
  interceptor_info["rank"] = tonumber(interceptor_info["rank"])
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(interceptor_info))
end

--[[
  获取最大排序值
--]]
function _M.get_max_rank()
  -- 从数据库获取最大排序值
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok, max_rank = xpcall(interceptor_service.get_max_rank, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(max_rank))
end

--[[
  创建拦截器
--]]
function _M.create_interceptor()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local interceptor_info = ngx.ctx.request:get_body_json()
  -- 创建拦截器
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok = xpcall(interceptor_service.create_interceptor, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, interceptor_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  更新拦截器
--]]
function _M.update_interceptor()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local interceptor_info = ngx.ctx.request:get_body_json()
  -- 更新拦截器
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok = xpcall(interceptor_service.update_interceptor, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, interceptor_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  删除拦截器
--]]
function _M.delete_interceptor()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local params = ngx.ctx.request:get_body_json()
  -- 删除拦截器
  local interceptor_service = module.require("service.interceptor")
  local call_err = ""
  local ok = xpcall(interceptor_service.delete_interceptor, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, params["ids"])
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

return _M
