#!/usr/bin/env lua
--[[

--]]
module(..., package.seeall)

function hello(request, response)
    local name = request:get_arg("name") or "world, try to give a param with name."
    response:writeln("hello, " .. name)
end