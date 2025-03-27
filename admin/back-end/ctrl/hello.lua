--[[

--]]

local res_util = require("utils.res_util")

local _M = {}

--[[
 获取普通参数/文件参数/请求体例子
--]]
function _M.hello(request, response, param)
    local name = request:get_arg("name") or "world, try to give a param with name."
    logger.info("name=", name)
    logger.info("param=", cjson.encode(param))
    response:set_content_type_json()
    response:writeln(res_util.success("hello, " .. name))
end

return _M