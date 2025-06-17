local ngx = require "ngx"
local module = require "core.module"
local error_util = require "utils.error_util"
local res_util = require "utils.res_util"

local _M = {}

--[[
  获取统计数据
--]]
function _M.get_data()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取代码列表
  local stats_service = module.require("service.stats")
  local call_err = ""
  local ok, data = xpcall(
    stats_service.get_data,
    function(err) call_err = error_util.get_msg(err) end,
    params
  )
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(data))
end

return _M
