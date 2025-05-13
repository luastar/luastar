--[===[
  路由管理模块
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"
local module = require "core.module"

local _M = {}

--[[
  获取路由列表
--]]
function _M.get_route_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {};
  -- 从数据库获取路由信息
  local route_service = module.require("service.route")
  local ok, route_count, route_list = xpcall(route_service.get_route_count_and_list, function(err)
    ngx.ctx.response:writeln(res_util.failure(err))
  end, params);
  if not ok then
    return
  end
  -- 返回结果
  local data = {
    pageNum = params["pageNum"],
    pageSize = params["pageSize"],
    total = route_count,
    list = route_list
  }
  ngx.ctx.response:set_content_type_json();
  ngx.ctx.response:writeln(res_util.success(data));
end

return _M
