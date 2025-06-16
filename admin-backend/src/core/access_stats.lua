local ngx = require "ngx"
local error_util = require "utils.error_util"

local _M = {}

_M.KEYS = {
  KEY_DICT_NAME = "dict_ls_stats",
  KEY_CONNECTIONS_ACTIVE = "stats:connections:active:",
  KEY_CONNECTIONS_READING = "stats:connections:reading:",
  KEY_CONNECTIONS_WRITING = "stats:connections:writing:",
  KEY_CONNECTIONS_WAITING = "stats:connections:waiting:",
  KEY_STATUS_2XX = "stats:status:2xx:",
  KEY_STATUS_3XX = "stats:status:3xx:",
  KEY_STATUS_4XX = "stats:status:4xx:",
  KEY_STATUS_5XX = "stats:status:5xx:",
  KEY_REQUESTS = "stats:requests:",
  KEY_RESPONSE_TIME_TOTAL = "stats:response_time:total:",
  KEY_RESPONSE_TIME_MAX = "stats:response_time:max:",
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
  local request_end_time = ngx.now()
  -- 当前时间戳(精确到分钟)
  local timestamp = math.floor(ngx.time() / 60) * 60
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]
  -- 记录连接数
  local connections_active = tonumber(ngx.var.connections_active) or 0
  local dict_connections_active = dict:get(_M.KEYS.KEY_CONNECTIONS_ACTIVE .. timestamp) or 0
  if connections_active > dict_connections_active then
    dict:set(_M.KEYS.KEY_CONNECTIONS_ACTIVE .. timestamp, connections_active)
  end
  local connections_reading = tonumber(ngx.var.connections_reading) or 0
  local dict_connections_reading = dict:get(_M.KEYS.KEY_CONNECTIONS_READING .. timestamp) or 0
  if connections_reading > dict_connections_reading then
    dict:set(_M.KEYS.KEY_CONNECTIONS_READING .. timestamp, connections_reading)
  end
  local connections_writing = tonumber(ngx.var.connections_writing) or 0
  local dict_connections_writing = dict:get(_M.KEYS.KEY_CONNECTIONS_WRITING .. timestamp) or 0
  if connections_writing > dict_connections_writing then
    dict:set(_M.KEYS.KEY_CONNECTIONS_WRITING .. timestamp, connections_writing)
  end
  local connections_waiting = tonumber(ngx.var.connections_waiting) or 0
  local dict_connections_waiting = dict:get(_M.KEYS.KEY_CONNECTIONS_WAITING .. timestamp) or 0
  if connections_waiting > dict_connections_waiting then
    dict:set(_M.KEYS.KEY_CONNECTIONS_WAITING .. timestamp, connections_waiting)
  end

  -- 记录状态码
  local status_code = ngx.status
  if status_code >= 200 and status_code < 300 then
    dict:incr(_M.KEYS.KEY_STATUS_2XX .. timestamp, 1, 0)
  elseif status_code >= 300 and status_code < 400 then
    dict:incr(_M.KEYS.KEY_STATUS_3XX .. timestamp, 1, 0)
  elseif status_code >= 400 and status_code < 500 then
    dict:incr(_M.KEYS.KEY_STATUS_4XX .. timestamp, 1, 0)
  elseif status_code >= 500 then
    dict:incr(_M.KEYS.KEY_STATUS_5XX .. timestamp, 1, 0)
  end

  -- 记录请求数
  dict:incr(_M.KEYS.KEY_REQUESTS .. timestamp, 1, 0)
  -- 记录总响应时间
  local request_start_time = ngx.ctx.start_time or ngx.req.start_time()
  local response_time = request_end_time - request_start_time
  dict:incr(_M.KEYS.KEY_RESPONSE_TIME_TOTAL .. timestamp, response_time, 0)
  -- 记录最大响应时间
  local response_time_max = dict:get(_M.KEYS.KEY_RESPONSE_TIME_MAX .. timestamp) or 0
  if response_time > response_time_max then
    dict:set(_M.KEYS.KEY_RESPONSE_TIME_MAX .. timestamp, response_time)
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
    -- 连接数
    local connections_active = dict:get(_M.KEYS.KEY_CONNECTIONS_ACTIVE .. t) or 0
    local connections_reading = dict:get(_M.KEYS.KEY_CONNECTIONS_READING .. t) or 0
    local connections_writing = dict:get(_M.KEYS.KEY_CONNECTIONS_WRITING .. t) or 0
    local connections_waiting = dict:get(_M.KEYS.KEY_CONNECTIONS_WAITING .. t) or 0
    table.insert(stats_data, {
      type = "connections",
      timestamp = t,
      timestamp_str = ts,
      value01 = connections_active,
      value02 = connections_reading,
      value03 = connections_writing,
      value04 = connections_waiting
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
    -- 请求
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
  end
  return stats_data
end

-- 删除统计数据
function _M.delete_stats_data(start_time, end_time)
  -- 数据字典
  local dict = ngx.shared[_M.KEYS.KEY_DICT_NAME]
  -- 循环每一分钟的数据
  for t = start_time, end_time, 60 do
    dict:delete(_M.KEYS.KEY_CONNECTIONS_ACTIVE .. t)
    dict:delete(_M.KEYS.KEY_CONNECTIONS_READING .. t)
    dict:delete(_M.KEYS.KEY_CONNECTIONS_WRITING .. t)
    dict:delete(_M.KEYS.KEY_CONNECTIONS_WAITING .. t)
    dict:delete(_M.KEYS.KEY_STATUS_2XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_3XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_4XX .. t)
    dict:delete(_M.KEYS.KEY_STATUS_5XX .. t)
    dict:delete(_M.KEYS.KEY_REQUESTS .. t)
    dict:delete(_M.KEYS.KEY_RESPONSE_TIME_MAX .. t)
    dict:delete(_M.KEYS.KEY_RESPONSE_TIME_TOTAL .. t)
  end
end

return _M
