--[===[
  路由管理模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
  获取路由列表
--]]
function _M.get_route_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取路由列表
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, count, list = xpcall(function()
    return route_service.get_route_count_and_list(params)
  end, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  local data = {
    total = count,
    list = list
  }
  ngx.ctx.response:writeln(res_util.success(data))
end

--[[
  获取路由信息
--]]
function _M.get_route_info()
  -- 获取查询参数
  local id = ngx.ctx.request:get_arg("id")
  -- 从数据库获取路由信息
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, route_info = xpcall(route_service.get_route_by_id, function(err)
    call_err = error_util.get_msg(err)
  end, id)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 转换数据类型
  route_info["rank"] = tonumber(route_info["rank"])
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(route_info))
end

--[[
  获取最大排序值
--]]
function _M.get_max_rank()
  -- 从数据库获取最大排序值
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, max_rank = xpcall(route_service.get_max_rank, function(err)
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
  创建路由
--]]
function _M.create_route()
  -- 获取请求参数
  local route_info = ngx.ctx.request:get_body_json()
  -- 创建路由
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, res = xpcall(route_service.create_route, function(err)
    call_err = error_util.get_msg(err)
  end, ngx.ctx.user_info, route_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(route_info["id"]))
end

--[[
  更新路由
--]]
function _M.update_route()
  -- 获取请求参数
  local route_info = ngx.ctx.request:get_body_json()
  -- 更新路由
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, res = xpcall(route_service.update_route, function(err)
    call_err = error_util.get_msg(err)
  end, ngx.ctx.user_info, route_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  删除路由
--]]
function _M.delete_route()
  -- 获取请求参数
  local params = ngx.ctx.request:get_body_json()
  local ids = params["ids"]
  -- 删除路由
  local route_service = module.require("service.route")
  local call_err = ""
  local ok, res = xpcall(route_service.delete_route, function(err)
    call_err = error_util.get_msg(err)
  end, ngx.ctx.user_info, ids)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

return _M
