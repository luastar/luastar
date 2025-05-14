--[[
	接口输出统一JSON格式
--]]
local ngx = require "ngx"

local _M = {}

function _M.invalid_argument(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "666",
		errMessage = msg or "Invalid Argument",
	}
	return cjson.encode(res)
end

function _M.invalid_access_token(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "401",
		errMessage = msg or "Invalid Access Token",
	}
	ngx.status = 401
	return cjson.encode(res)
end

function _M.invalid_refresh_token(msg)
	local res = {
		traceId = ngx.ctx.trace_id,
		success = false,
		errCode = "402",
		errMessage = msg or "Invalid Refresh Token",
	}
	ngx.status = 402
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
	ngx.status = 500
	return cjson.encode(res)
end

return _M
