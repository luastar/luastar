--[[

--]]
local _M = {}

--[[
 多语言
--]]
function _M.msg(request, response, param)
    local ns = request:get_arg("ns")
    local key = request:get_arg("key")
    ngx.log(logger.i("ns=", ns, ", key=", key))
    local content = luastar_context.get_msg(ns, key)
    response:writeln(content)
end

return _M