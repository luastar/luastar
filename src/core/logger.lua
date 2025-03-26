--[[
ngx.log 辅助输出，可加入日志标记，便于跟踪日志
--]]
local _M = {}

function _M.debug(...)
	if ngx.ctx and ngx.ctx.trace_id then
		ngx.log(ngx.DEBUG, "--[", ngx.ctx.trace_id, "]--", ...)
		return
	end
	ngx.log(ngx.DEBUG, ...)
end

function _M.info(...)
	if ngx.ctx and ngx.ctx.trace_id then
		ngx.log(ngx.INFO, "--[", ngx.ctx.trace_id, "]--", ...)
		return
	end
	ngx.log(ngx.INFO, ...)
end

function _M.warn(...)
	if ngx.ctx and ngx.ctx.trace_id then
		ngx.log(ngx.WARN, "--[", ngx.ctx.trace_id, "]--", ...)
		return
	end
	ngx.log(ngx.WARN, ...)
end

function _M.error(...)
	if ngx.ctx and ngx.ctx.trace_id then
		ngx.log(ngx.ERR, "--[", ngx.ctx.trace_id, "]--", ...)
		return
	end
	ngx.log(ngx.ERR, ...)
end

return _M
