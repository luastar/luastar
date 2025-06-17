--[[
	日期时间工具
--]]
local ngx = require "ngx"

local _M = {}

-- 获取当前时间戳
function _M.get_ngx_time()
  return ngx.time()
end

-- 获取当前日期
function _M.get_ngx_today()
  return ngx.today()
end

-- 获取当前日期(%Y-%m-%d)
function _M.get_date()
  return os.date("%Y-%m-%d", ngx.time())
end

-- 获取当前日期(%Y-%m-%d %H:%M:%S)
function _M.get_time()
  return os.date("%Y-%m-%d %H:%M:%S", ngx.time())
end

-- 获取当前日期(%Y%m%d%H%M%S)
function _M.get_time2()
  return os.date("%Y%m%d%H%M%S", ngx.time())
end

function _M.fmt_time(format, time)
  return os.date(format, time)
end

-- 解析'%Y-%m-%d %H:%M:%S'的时间格式
function _M.parse_time(t)
  if t == nil or type(t) ~= "string" or #t == 0 then
    return ngx.time()
  end
  local year, month, day, hour, min, sec = string.match(t, "^(%d%d%d%d)%-(%d%d?)%-(%d%d?)%s*(%d%d?):(%d%d?):(%d%d?)$")
  if year == nil or month == nil or day == nil or hour == nil or min == nil or sec == nil then
    return ngx.time()
  end
  return os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec })
end

-- 解析'%Y-%m-%d %H:%M:%S'的时间格式
function _M.parse_time2(t)
  local now = _M.parse_time(t)
  return {
    year = os.date("%Y", now),
    month = os.date("%m", now),
    day = os.date("%d", now),
    hour = os.date("%H", now),
    min = os.date("%M", now),
    sec = os.date("%S", now)
  }
end

return _M
