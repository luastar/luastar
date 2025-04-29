--[===[
  路由管理模块
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"

local _M = {}

--[[
  获取路由列表
--]]
function _M.route_list(params)
  local data = {};
  ngx.ctx.response:set_content_type_json();
  ngx.ctx.response:writeln(res_util.success(data));
end

return _M
