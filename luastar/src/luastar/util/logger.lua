#!    /usr/bin/env lua
--[[
ngx.log辅助输出，可加入日志标记，便于跟踪日志
--]]
module(..., package.seeall)

function debug(...)
    if ngx.ctx and ngx.ctx.log_sign then
        return ngx.DEBUG, ngx.ctx.log_sign, ...
    end
    return ngx.DEBUG, ...
end

function info(...)
    if ngx.ctx and ngx.ctx.log_sign then
        return ngx.INFO, ngx.ctx.log_sign, ...
    end
    return ngx.INFO, ...
end

function warn(...)
    if ngx.ctx and ngx.ctx.log_sign then
        return ngx.WARN, ngx.ctx.log_sign, ...
    end
    return ngx.WARN, ...
end

function error(...)
    if ngx.ctx and ngx.ctx.log_sign then
        return ngx.ERR, ngx.ctx.log_sign, ...
    end
    return ngx.ERR, ...
end

do
    d = debug
    i = info
    w = warn
    e = error
end
