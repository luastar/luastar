#!/usr/bin/env lua
--[[

--]]
module(..., package.seeall)
local httpclient = require("luastar.util.httpclient")

function baidu(request, response)
    local res_ok, res_code, res_headers, res_status, res_body = httpclient.request_http({
        url = "http://www.baidu.com"
    })
    if not res_ok or _.isEmpty(res_body) then
        response:writeln("访问百度失败。")
        return
    end
    response:writeln(res_body)
end