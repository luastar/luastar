--[[

--]]
local _M = {}

--[[
 多语言
--]]
function _M.msg(request, response, param)
    local key = request:get_arg("key")
    ngx.log(logger.i("key = ", key))
    local content = luastar_context.get_msg(key)
    response:writeln(content)
end

return _M