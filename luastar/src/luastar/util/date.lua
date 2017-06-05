--[[
	
]]

local _M = {}

function _M.get_ngx_time()
	return ngx.time()
end

function _M.get_ngx_today()
	return ngx.today()
end

function _M.get_date()
	return os.date('%Y-%m-%d', ngx.time())
end

function _M.get_time()
	return os.date('%Y-%m-%d %H:%M:%S', ngx.time())
end

function _M.get_time2()
	return os.date('%Y%m%d%H%M%S', ngx.time())
end

-- 解析'%Y-%m-%d %H:%M:%S'的时间格式
function _M.parse_time(t)
	if t == nil or type(t) ~= 'string' or #t == 0 then
		return ngx.time()
	end
	local year, month, day, hour, min, sec = string.match(t, "^(%d%d%d%d)%-(%d%d?)%-(%d%d?)%s*(%d%d?):(%d%d?):(%d%d?)$")
	if year == nil or month == nil or day == nil or hour == nil or min == nil or sec == nil then
		return ngx.time()
	end
	return os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec)
	})
end

return _M