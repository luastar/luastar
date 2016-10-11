#! /usr/bin/env lua
--[[
异常处理拦截器
--]]
module(..., package.seeall)

local json_util = require("com.luastar.demo.util.json")
local random = require("resty.random")

function beforeHandle()
    local request = ngx.ctx.request
    local headParam = {}
    headParam["appkey"] = request:get_header("appkey") or ""
    headParam["appversion"] = request:get_header("apiversion") or ""
    headParam["ostype"] = request:get_header("ostype") or ""
    ngx.log(logger.i("request header is ", cjson.encode(headParam)))
    -- 统一校验请求头信息
--    local hasEmpty = _.any(_.values(headParam), function(v) if _.isEmpty(v) then return true end end)
--    return not hasEmpty
    return true
end

function afterHandle(ctrl_call_ok, err_info)
    if not ctrl_call_ok then
        ngx.ctx.response:writeln(json_util.exp(err_info))
    end
end
