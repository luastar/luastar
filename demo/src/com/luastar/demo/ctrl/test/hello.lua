#!/usr/bin/env lua
--[[

--]]
module(..., package.seeall)

function hello(request, response)
    local name = request:get_arg("name") or "world, try to give a param with name."
    ngx.log(logger.i("name=", name))
    local file = request:get_arg("file")
    if not _.isEmpty(file) then
        local file_save = io.open("/Users/zhuminghua/Downloads/output/"..file["filename"],"w")
        file_save:write(file["value"]);
        file_save:close();
    end
    response:writeln("hello, " .. name)
end