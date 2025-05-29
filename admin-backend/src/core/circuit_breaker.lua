local ngx = require "ngx"
local config = require "core.config"
local error_util = require "utils.error_util"

local _M = {}
local mt = { __index = _M }

-- 策略类型
local STRATEGY = {
  SLOW_REQUEST_RATIO = "SLOW_REQUEST_RATIO",
  ERROR_RATIO = "ERROR_RATIO",
  ERROR_COUNT = "ERROR_COUNT",
}

-- 熔断器状态
local STATE = {
  CLOSED = "CLOSED",
  OPEN = "OPEN",
  HALF_OPEN = "HALF_OPEN",
}

-- 默认配置
local DEFAULT_CONFIG = {
  -- 基础配置
  strategy = STRATEGY.SLOW_REQUEST_RATIO, -- 策略类型
  stat_interval = 60,                     -- 统计时间窗口(秒)
  bucket_count = 10,                      -- 桶数量
  min_request_amount = 5,                 -- 最小请求数
  circuit_breaker_timeout = 30,           -- 熔断时长(秒)
  -- 慢调用比例策略配置
  slow_request_ratio = {
    max_rt = 2000,  -- 最大响应时间(ms)
    threshold = 0.5 -- 慢调用比例阈值
  },
  -- 异常比例策略配置
  error_ratio = {
    threshold = 0.5 -- 异常比例阈值
  },
  -- 异常数策略配置
  error_count = {
    threshold = 5 -- 异常数阈值
  },
  -- 半开状态配置
  half_open = {
    max_requests = 10,       -- 最大允许请求数
    min_sample_count = 5,    -- 最小样本数
    success_threshold = 0.8, -- 成功率阈值(恢复)
    failure_threshold = 0.2, -- 失败率阈值(重新熔断)
  },
}

-- 初始化熔断器
function _M:new(res_key)
  -- 获取资源配置参数
  local breaker_config = config.get_config("circuit_breaker." .. res_key) or {}
  local config = _.defaults(breaker_config, DEFAULT_CONFIG)
  -- 参数校验
  if config["stat_interval"] <= 1 then
    error_util.throw("统计周期[stat_interval]不能小于1秒")
  end
  if config["bucket_count"] <= 1 then
    error_util.throw("桶数量[bucket_count]不能小于1个")
  end
  config["bucket_interval"] = config["stat_interval"] / config["bucket_count"]
  -- 类实例属性
  local instance = {
    res_key = res_key,
    config = config,
    key_state = res_key .. ":state",
    key_bucket_time = res_key .. ":bucket:time:",
    key_bucket_request = res_key .. ":bucket:request:",
    key_bucket_slow = res_key .. ":bucket:slow:",
    key_bucket_error = res_key .. ":bucket:error:",
    key_open_time = res_key .. ":open:time",
    key_half_open_request = res_key .. ":half_open:request",
    key_half_open_success = res_key .. ":half_open:success",
  }
  -- 初始化状态
  local dict = ngx.shared.dict_ls_traffic
  if not dict then
    error_util.throw("字典[dict_ls_traffic]未配置")
  end
  local state = dict:get(instance.key_state)
  if not state then
    dict:set(instance.key_state, STATE.CLOSED)
  end
  setmetatable(instance, mt)
  return instance
end

-- 获取时间戳所在的桶索引
function _M:get_bucket_index(current_time)
  return math.floor((current_time % self.config["stat_interval"]) / self.config["bucket_interval"]) + 1
end

-- 获取时间戳的统计信息
function _M:get_stat_info(current_time)
  -- 汇总每个桶的数据
  local dict = ngx.shared.dict_ls_traffic
  local amount_request, amount_slow, amount_error = 0, 0, 0
  for i = 1, self.config["bucket_count"] do
    local bucket_time = dict:get(self.key_bucket_time .. i) or 0
    -- 只统计时间窗口内的桶数据
    if current_time - bucket_time <= self.config["stat_interval"] then
      local bucket_request = dict:get(self.key_bucket_request .. i) or 0
      amount_request = amount_request + bucket_request
      local bucket_slow = dict:get(self.key_bucket_slow .. i) or 0
      amount_slow = amount_slow + bucket_slow
      local bucket_error = (dict:get(self.key_bucket_error .. i) or 0)
      amount_error = amount_error + bucket_error
    end
  end
  return {
    amount_request = amount_request,
    amount_slow = amount_slow,
    amount_error = amount_error,
  }
end

-- 检查是否需要熔断
function _M.check_circuit_breaker(self)
  -- 获取状态
  local dict = ngx.shared.dict_ls_traffic
  local state = dict:get(self.key_state)

  -- 如果是 OPEN 状态，检查是否应该进入 HALF_OPEN
  if state == STATE.OPEN then
    local last_open_time = dict:get(self.key_open_time) or 0
    if ngx.now() - last_open_time > self.config["circuit_breaker_timeout"] then
      dict:set(self.key_state, STATE.HALF_OPEN)
      return false
    end
    return true
  end

  -- 如果是 HALF_OPEN 状态，允许固定数量请求通过
  if state == STATE.HALF_OPEN then
    -- 获取半开状态统计
    local half_open_request = dict:get(self.key_half_open_request) or 0
    -- 检查是否已达到最大请求数
    if half_open_request >= self.config["half_open"]["max_requests"] then
      return true
    end
    -- 允许请求通过
    return false
  end

  -- 如果是 CLOSED 状态，检查是否需要熔断
  local current_time = ngx.now()
  local stat_info = self:get_stat_info(current_time)
  -- 检查请求数是否达到最小阈值
  if stat_info["amount_request"] < self.config["min_request_amount"] then
    return false
  end
  -- 根据策略检查是否需要熔断
  if self.config["strategy"] == STRATEGY.SLOW_REQUEST_RATIO then
    local slow_ratio = stat_info["amount_slow"] / stat_info["amount_request"]
    if slow_ratio > self.config["slow_request_ratio"]["threshold"] then
      dict:set(self.key_state, STATE.OPEN)
      dict:set(self.key_open_time, current_time)
      return true
    end
  elseif self.config["strategy"] == STRATEGY.ERROR_RATIO then
    local error_ratio = stat_info["amount_error"] / stat_info["amount_request"]
    if error_ratio > self.config["error_ratio"]["threshold"] then
      dict:set(self.key_state, STATE.OPEN)
      dict:set(self.key_open_time, current_time)
      return true
    end
  elseif self.config["strategy"] == STRATEGY.ERROR_COUNT then
    if stat_info["amount_error"] > self.config["error_count"]["threshold"] then
      dict:set(self.key_state, STATE.OPEN)
      dict:set(self.key_open_time, current_time)
      return true
    end
  end
  return false
end

-- 记录请求结果
function _M:record_request(self)
  -- 获取当前时间和桶索引
  local current_time = ngx.now()
  local bucket_index = self:get_bucket_index(current_time)
  local rt = (current_time - ngx.ctx.circuit_breaker_start_time) * 1000
  local is_slow = rt > self.config["slow_request_ratio"]["max_rt"]
  local is_error = ngx.status >= 500
  -- 检查桶是否过期，如果过期则重置
  local dict = ngx.shared.dict_ls_traffic
  local bucket_time = dict:get(self.key_bucket_time .. bucket_index) or 0
  if current_time - bucket_time > self.config["bucket_interval"] then
    -- 重置桶数据
    dict:set(self.key_bucket_time .. bucket_index, current_time)
    dict:set(self.key_bucket_request .. bucket_index, 0)
    dict:set(self.key_bucket_slow .. bucket_index, 0)
    dict:set(self.key_bucket_error .. bucket_index, 0)
  else
    -- 更新桶数据
    dict:incr(self.key_bucket_request .. bucket_index, 1, 0)
    if is_slow then dict:incr(self.key_bucket_slow .. bucket_index, 1, 0) end
    if is_error then dict:incr(self.key_bucket_error .. bucket_index, 1, 0) end
  end

  -- 半开状态数据更新
  local state = dict:get(self.key_state)
  if state == STATE.HALF_OPEN then
    -- 记录请求数和成功数
    dict:incr(self.key_half_open_request, 1, 0)
    if not is_slow and not is_error then
      dict:incr(self.key_half_open_success, 1, 0)
    end
    -- 获取统计信息
    local half_open_request = dict:get(self.key_half_open_request) or 0
    local half_open_success = dict:get(self.key_half_open_success) or 0
    -- 达到最小样本数才做决策
    if half_open_request >= self.config["half_open"]["min_sample_count"] then
      local success_rate = half_open_success / half_open_request
      -- 成功率达标，恢复服务
      if success_rate >= self.config.config["half_open"]["success_threshold"] then
        dict:set(self.key_state, STATE.CLOSED)
        -- 重置所有桶的统计数据
        for i = 1, self.config["bucket_count"] do
          dict:set(self.key_bucket_time .. i, ngx.now())
          dict:set(self.key_bucket_request .. i, 0)
          dict:set(self.key_bucket_slow .. i, 0)
          dict:set(self.key_bucket_error .. i, 0)
        end
        -- 重置半开状态统计
        dict:set(self.key_half_open_request, 0)
        dict:set(self.key_half_open_success, 0)
        -- 失败率达标，重新熔断
      elseif success_rate <= self.config["half_open"]["failure_threshold"] then
        dict:set(self.key_state, STATE.OPEN)
        dict:set(self.key_open_time, ngx.now())
        -- 重置半开状态统计
        dict:set(self.key_half_open_request, 0)
        dict:set(self.key_half_open_success, 0)
      end
    end
  end
end

return _M
