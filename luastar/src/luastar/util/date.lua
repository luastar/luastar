#!   /usr/bin/env lua
--[[
	
]]

module(..., package.seeall)

local str_util = require("luastar.util.str")

function get_ngx_time()
    return ngx.time()
end

function get_ngx_today()
    return ngx.today()
end

function get_timestamp()
    return os.date('%Y%m%d%H%M%S', ngx.time())
end

function get_timestamp2()
    return os.date('%Y-%m-%d %H:%M:%S', ngx.time())
end

function parse_time(r)
    local a = str_util.split(r, " ")
    local b = str_util.split(a[1], "-")
    local c = str_util.split(a[2], ":")
    return os.time({ year = b[1], month = b[2], day = b[3], hour = c[1], min = c[2], sec = c[3] })
end
