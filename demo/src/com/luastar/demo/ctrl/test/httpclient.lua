#!/usr/bin/env lua
--[[

--]]
module(..., package.seeall)
local httpclient = require("luastar.util.httpclient")

function baidu(request, response)
    local request_method = request.request_method
    local query_string = request.query_string or ""
    local headers = request.headers
    local body = request:get_request_body()
    ngx.log(logger.i(cjson.encode({
        query_string = query_string,
        request_method = request_method,
        headers = headers,
--        body = body
    })))
    local res_ok, res_code, res_headers, res_status, res_body = httpclient.request_http({
        url = "http://127.0.0.1:8001/api/test/hello?" .. query_string,
        method = request_method,
        headers = headers,
        body = body
    })
    if not res_ok or _.isEmpty(res_body) then
        response:writeln("访问失败。")
        return
    end
    response:writeln(res_body)
end