--[[
日志模块
--]]
local ngx = require "ngx"

local _M = {}

function _M.debug(...)
	local info = debug.getinfo(2, "Sl")
	local trace_id = ngx.ctx.trace_id or ""
	ngx.log(ngx.DEBUG, "[", info.short_src, ":", info.currentline, "]", "[", trace_id, "]", ...)
end

function _M.info(...)
	local info = debug.getinfo(2, "Sl")
	local trace_id = ngx.ctx.trace_id or ""
	ngx.log(ngx.INFO, "[", info.short_src, ":", info.currentline, "]", "[", trace_id, "]", ...)
end

function _M.warn(...)
	local info = debug.getinfo(2, "Sl")
	local trace_id = ngx.ctx.trace_id or ""
	ngx.log(ngx.WARN, "[", info.short_src, ":", info.currentline, "]", "[", trace_id, "]", ...)
end

function _M.error(...)
	local info = debug.getinfo(2, "Sl")
	local trace_id = ngx.ctx.trace_id or ""
	ngx.log(ngx.ERR, "[", info.short_src, ":", info.currentline, "]", "[", trace_id, "]", ...)
end

return _M
