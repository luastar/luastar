--[[

--]]

local res_util = require("utils.res_util")

local _M = {}

--[[
 健康检查
--]]
function _M.check(request, response)
    response:set_content_type_json()
    response:writeln(res_util.success())
end

return _M
