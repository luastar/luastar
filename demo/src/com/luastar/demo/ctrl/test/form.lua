--[[

--]]
local _M = {}

local file_util = require("luastar.util.file")

function _M.form(request, response)
    local form = {}
    form["phone"] = request:get_arg("phone") or ""
    form["userName"] = request:get_arg("userName") or ""
    form["sex"] = tonumber(request:get_arg("sex")) or 2
    local pic = request:get_arg("pic")
    if not _.isEmpty(pic) then
        local filedir = "/Users/zhuminghua/Downloads/upload/demo"
        local filepath = filedir .. "/" .. pic.filename
        local file, err = io.open(filepath, "w")
        if file == nil then
            ngx.log(logger.info("open file fail : ", err))
            file_util.mkdir(filedir)
            file = io.open(filepath, "w")
        end
        if file ~= nil then
            ngx.log(logger.info("open file ok."))
            file:write(pic.value)
            file:close()
            form["pic"] = filepath
        end
    end
    response:writeln(cjson.encode(form))
end

return _M