#!    /usr/bin/env lua
--[[
ngx.log辅助输出，可加入日志标记，便于跟踪日志
--]]
module(..., package.seeall)

function debug(...)
    if ngx.ctx and ngx.ctx.request_id then
        return ngx.DEBUG, "--[", ngx.ctx.request_id, "]--", ...
    end
    return ngx.DEBUG, ...
end

function info(...)
    if ngx.ctx and ngx.ctx.request_id then
        return ngx.INFO, "--[", ngx.ctx.request_id, "]--", ...
    end
    return ngx.INFO, ...
end

function warn(...)
    if ngx.ctx and ngx.ctx.request_id then
        return ngx.WARN, "--[", ngx.ctx.request_id, "]--", ...
    end
    return ngx.WARN, ...
end

function error(...)
    if ngx.ctx and ngx.ctx.request_id then
        return ngx.ERR, "--[", ngx.ctx.request_id, "]--", ...
    end
    return ngx.ERR, ...
end

do
    d = debug
    i = info
    w = warn
    e = error
end
