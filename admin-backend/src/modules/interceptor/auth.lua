--[===[
    拦截器
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"

local _M = {}

function _M.handle_before()
  logger.info("执行拦截器 handle_before 方法")
  return true
end

function _M.handle_after()
  logger.info("执行拦截器 handle_after 方法")
  local handle_res = ngx.ctx.handle_res
  if not handle_res.ok then
    ngx.ctx.response:set_content_type_json()
    ngx.ctx.response:writeln(res_util.error(handle_res.err))
  end
end

return _M
