--[[
ngx.log辅助输出，可加入日志标记，便于跟踪日志
--]]
local _M = {}

function _M.debug(...)
	if ngx.ctx and ngx.ctx.request_id then
		return ngx.DEBUG, "--[", ngx.ctx.request_id, "]--", ...
	end
	return ngx.DEBUG, ...
end

function _M.info(...)
	if ngx.ctx and ngx.ctx.request_id then
		return ngx.INFO, "--[", ngx.ctx.request_id, "]--", ...
	end
	return ngx.INFO, ...
end

function _M.warn(...)
	if ngx.ctx and ngx.ctx.request_id then
		return ngx.WARN, "--[", ngx.ctx.request_id, "]--", ...
	end
	return ngx.WARN, ...
end

function _M.error(...)
	if ngx.ctx and ngx.ctx.request_id then
		return ngx.ERR, "--[", ngx.ctx.request_id, "]--", ...
	end
	return ngx.ERR, ...
end

do
	_M.d = _M.debug
	_M.i = _M.info
	_M.w = _M.warn
	_M.e = _M.error
end

return _M
