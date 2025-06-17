local ngx = require "ngx"
local error_util = require "utils.error_util"

local _M = {}

_M.KEYS = {
  KEY_DICT_NAME = "dict_ls_stats",
  KEY_REQUESTS = "stats:requests:",
  KEY_RESPONSE_TIME_TOTAL = "stats:response_time:total:",
  KEY_RESPONSE_TIME_MAX = "stats:response_time:max:",
  KEY_STATUS_2XX = "stats:status:2xx:",
  KEY_STATUS_3XX = "stats:status:3xx:",
  KEY_STATUS_4XX = "stats:status:4xx:",
  KEY_STATUS_5XX = "stats:status:5xx:",
  KEY_LAST_PERSIST_TIME = "stats:last_persist_time",
}

function _M.init()
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]
  if not dict then
    error_util.throw("数据字典未配置")
  end
end

-- 记录访问统计
function _M.record_access()
  -- 请求结束时间
  local request_end_time = ngx.now() * 1000
  -- 当前时间戳(精确到分钟)
  local timestamp = math.floor(ngx.time() / 60) * 60
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]

  -- 记录请求数
  dict:incr(_M.KEYS.KEY_REQUESTS .. timestamp, 1, 0)
  -- 记录总响应时间
  local request_start_time = ngx.ctx.start_time or (ngx.req.start_time() * 1000)
  local response_time = request_end_time - request_start_time
  dict:incr(_M.KEYS.KEY_RESPONSE_TIME_TOTAL .. timestamp, response_time, 0)
  -- 记录最大响应时间
  local response_time_max = dict:get(_M.KEYS.KEY_RESPONSE_TIME_MAX .. timestamp) or 0
  if response_time > response_time_max then
    dict:set(_M.KEYS.KEY_RESPONSE_TIME_MAX .. timestamp, response_time)
  end

  -- 记录状态码
  local status_code = ngx.ctx.exit_status or ngx.status
  if status_code >= 200 and status_code < 300 then
    dict:incr(_M.KEYS.KEY_STATUS_2XX .. timestamp, 1, 0)
  elseif status_code >= 300 and status_code < 400 then
    dict:incr(_M.KEYS.KEY_STATUS_3XX .. timestamp, 1, 0)
  elseif status_code >= 400 and status_code < 500 then
    dict:incr(_M.KEYS.KEY_STATUS_4XX .. timestamp, 1, 0)
  elseif status_code >= 500 then
    dict:incr(_M.KEYS.KEY_STATUS_5XX .. timestamp, 1, 0)
  end
end

-- 获取统计数据
function _M.get_stats_data(start_time, end_time)
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]
  -- 获取统计数据
  local stats_data = {}
  -- 循环每一分钟的数据
  for t = start_time, end_time, 60 do
    local ts = os.date("%Y-%m-%d %H:%M:%S", t)
    -- 请求数
    local requests = dict:get(_M.KEYS.KEY_REQUESTS .. t) or 0
    local request_max_time = dict:get(_M.KEYS.KEY_RESPONSE_TIME_MAX .. t) or 0
    local request_total_time = dict:get(_M.KEYS.KEY_RESPONSE_TIME_TOTAL .. t) or 0
    local request_avg_time = 0
    if requests > 0 then
      request_avg_time = request_total_time / requests
    end
    table.insert(stats_data, {
      type = "requests",
      timestamp = t,
      timestamp_str = ts,
      value01 = requests,
      value02 = request_max_time,
      value03 = request_avg_time,
    })
    -- 状态码
    local status_2xx = dict:get(_M.KEYS.KEY_STATUS_2XX .. t) or 0
    local status_3xx = dict:get(_M.KEYS.KEY_STATUS_3XX .. t) or 0
    local status_4xx = dict:get(_M.KEYS.KEY_STATUS_4XX .. t) or 0
    local status_5xx = dict:get(_M.KEYS.KEY_STATUS_5XX .. t) or 0
    table.insert(stats_data, {
      type = "status",
      timestamp = t,
      timestamp_str = ts,
      value01 = status_2xx,
      value02 = status_3xx,
      value03 = status_4xx,
      value04 = status_5xx
    })
  end
  return stats_data
end

-- 删除统计数据
function _M.delete_stats_data(start_time, end_time)
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]
  -- 循环每一分钟的数据
  for t = start_time, end_time, 60 do
    dict:delete(_M.KEYS.KEY_REQUESTS .. t)
    dict:delete(_M.KEYS.KEY_RESPONSE_TIME_MAX .. t)
    dict:delete(_M.KEYS.KEY_RESPONSE_TIME_TOTAL .. t)
    dict:delete(_M.KEYS.KEY_STATUS_2XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_3XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_4XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_5XX .. t)
  end
end

return _M
