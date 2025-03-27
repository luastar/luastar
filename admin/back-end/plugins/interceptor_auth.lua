--[[
    拦截器
--]]
local _M = {}

local res_util = require("utils.res_util")

function _M.beforeHandle()
    ngx.ctx.response:reset_output()
    ngx.ctx.response:set_content_type_json()
    ngx.ctx.response:writeln(res_util.success({
        code = 200,
        message = "interceptor success"
    }))
    return false
end

function _M.afterHandle(ctrl_call_ok, err_info)
    ngx.ctx.response:set_content_type_json()
    if not ctrl_call_ok then
        ngx.ctx.response:writeln(res_util.error(err_info))
    end
end

return _M