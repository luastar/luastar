--[[
健康检查
--]]

local res_util = require "utils.res_util"

local _M = {}

--[[
当前服务是否正常
--]]
function _M.handle(request, response)
    response:set_content_type_json()
    response:writeln(res_util.success())
end

return _M
