--[===[
    健康检查
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"

local _M = {}

function _M.handle(params)
  ngx.ctx.response:set_content_type_json()
  ngx.ctx.response:writeln(res_util.success({ isActive = true }))
end

return _M
