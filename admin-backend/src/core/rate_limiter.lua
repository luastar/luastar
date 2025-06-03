local ngx = require "ngx"
local resty_limit_count = require "resty.limit.count"
local resty_limit_conn = require "resty.limit.conn"
local resty_limit_req = require "resty.limit.req"
local config = require "core.config"
local error_util = require "utils.error_util"

local _M = {}
local mt = { __index = _M }

-- 策略类型
local STRATEGY = {
  COUNT = "COUNT",
  CONN = "CONN",
  REQ = "REQ"
}

-- 默认配置
local DEFAULT_CONFIG = {
  -- 基础配置
  strategy = STRATEGY.COUNT, -- 策略类型
  -- 请求数量限流
  count = {
    time_window = 60, -- 时间窗口(秒)
    count = 100,      -- 指定的请求数量阈值
  },
  -- 请求并发限流
  conn = {
    conn = 200,               -- 允许同时进行的请求数量
    burst = 100,              -- 允许延迟的过量并发请求数量
    default_conn_delay = 0.5, -- 默认处理延迟时间(秒)
  },
  -- 请求速率限流
  req = {
    rate = 200,  -- 指定的请求速率（每秒的次数）阈值
    burst = 100, -- 每秒允许延迟处理的过多请求数量
  }
}

-- 初始化
function _M:new(res_key)
  -- 获取资源配置参数
  local limiter_config = config.get_config("rate_limiter." .. res_key) or {}
  local current_config = _.defaults(limiter_config, DEFAULT_CONFIG)
  -- 存储字典
  local dict_name = "dict_ls_traffic"
  if not ngx.shared[dict_name] then
    error_util.throw("字典[dict_ls_traffic]未配置")
  end
  local instance = {
    res_key = res_key,
    config = current_config,
    dict_name = dict_name,
  }
  return setmetatable(instance, mt)
end

-- 请求数量限流
function _M:check_count()
  -- rate: count requests per time_window seconds
  local lim, err = resty_limit_count.new(self.dict_name, self.config["count"]["count"], self.config["count"]["time_window"])
  if not lim then
    logger.error("failed to instantiate a resty.limit.count object: ", err)
    return false
  end
  local delay, err = lim:incoming(self.res_key, true)
  if not delay then
    if err == "rejected" then
      ngx.header["X-RateLimit-Limit"] = self.config["count"]["count"]
      ngx.header["X-RateLimit-Remaining"] = 0
      return true
    end
    logger.error("failed to limit count: ", err)
    return false
  end
  -- the 2nd return value holds the current remaining number of requests for the specified key.
  local remaining = err
  ngx.header["X-RateLimit-Limit"] = self.config["count"]["count"]
  ngx.header["X-RateLimit-Remaining"] = remaining
  return false
end

-- 请求并发限流
function _M:check_conn()
  -- limit the requests under 200 concurrent requests, with a burst of 100 extra concurrent requests,
  -- that is, we delay requests under 300 concurrent connections and above 200 connections,
  -- and reject any new requests exceeding 300 connections.
  -- also, we assume a default request time of 0.5 sec
  local lim, err = resty_limit_conn.new(self.dict_name, self.config["conn"]["conn"], self.config["conn"]["burst"], self.config["conn"]["default_conn_delay"])
  if not lim then
    logger.error("failed to instantiate a resty.limit.conn object: ", err)
    return false
  end
  -- the following call must be per-request.
  local delay, err = lim:incoming(self.res_key, true)
  if not delay then
    if err == "rejected" then
      return true
    end
    logger.error("failed to limit req: ", err)
    return false
  end
  if lim:is_committed() then
    ngx.ctx.limit_conn = lim
    ngx.ctx.limit_conn_key = self.res_key
    ngx.ctx.limit_conn_delay = delay
  end
  -- the 2nd return value holds the current concurrency level for the specified key.
  local conn = err
  if delay >= 0.001 then
    -- the request exceeding the 200 connections ratio but below 300 connections,
    -- so we intentionally delay it here a bit to conform to the 200 connection limit.
    logger.warn("delaying")
    ngx.sleep(delay)
  end
  return false
end

-- 请求速率限流
function _M:check_req()
  -- limit the requests under 200 req/sec with a burst of 100 req/sec,
  -- that is, we delay requests under 300 req/sec and above 200 req/sec,
  -- and reject any requests exceeding 300 req/sec.
  local lim, err = resty_limit_req.new(self.dict_name, self.config["req"]["rate"], self.config["req"]["burst"])
  if not lim then
    ngx.log(ngx.ERR, "failed to instantiate a resty.limit.req object: ", err)
    return false
  end

  local delay, err = lim:incoming(self.res_key, true)
  if not delay then
    if err == "rejected" then
      return true
    end
    ngx.log(ngx.ERR, "failed to limit req: ", err)
    return false
  end
  if delay >= 0.001 then
    -- the 2nd return value holds the number of excess requests per second for the specified key.
    -- for example, number 31 means the current request rate is at 231 req/sec for the specified key.
    local excess = err
    -- the request exceeding the 200 req/sec but below 300 req/sec,
    -- so we intentionally delay it here a bit to conform to the 200 req/sec rate.
    ngx.sleep(delay)
  end
  return false
end

-- 检查限流
function _M:check_limit()
  if self.config["strategy"] == STRATEGY.COUNT then
    return self:check_count()
  elseif self.config["strategy"] == STRATEGY.CONN then
    return self:check_conn()
  elseif self.config["strategy"] == STRATEGY.REQ then
    return self:check_req()
  end
  return false
end

-- 清理工作
function _M:cleanup()
  -- 释放链接
  local lim = ngx.ctx.limit_conn
  if lim then
    -- if you are using an upstream module in the content phase,
    -- then you probably want to use $upstream_response_time
    -- instead of ($request_time - ctx.limit_conn_delay) below.
    local latency = tonumber(ngx.var.request_time) - ngx.ctx.limit_conn_delay
    local conn, err = lim:leaving(ngx.ctx.limit_conn_key, latency)
    if not conn then
      logger.error("failed to record the connection leaving request: ", err)
      return
    end
  end
end

return _M
