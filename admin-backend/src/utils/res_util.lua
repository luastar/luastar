--[[
	接口输出统一JSON格式
--]]
local _M = {}

function _M.illegal_argument(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "666",
		errMessage = msg or "Illegal Argument",
	}
	return cjson.encode(res)
end

function _M.illegal_auth(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "401",
		errMessage = msg or "Illegal Authorization",
	}
	return cjson.encode(res)
end

function _M.success(data, needFormat)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = true,
		data = data
	}
	if needFormat then
		return string.gsub(cjson.encode(res), "{}", "[]")
	end
	return cjson.encode(res)
end

function _M.failure(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "888",
		errMessage = msg or "failure",
	}
	return cjson.encode(res)
end

function _M.error(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "500",
		errMessage = msg or "System Error",
	}
	return cjson.encode(res)
end

return _M


