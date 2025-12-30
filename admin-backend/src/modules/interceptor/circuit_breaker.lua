local ngx = require "ngx"
local config = require "core.config"
local circuit_breaker = require "core.circuit_breaker"
local res_util = require "utils.res_util"

local _M = {}

-- 降级策略
local FALLBACK_STRATEGY = {
  THROW_EXCEPTION = "throw_exception",
  RETURN_MOCK_DATA = "return_mock_data",
}

-- 前置处理
function _M.handle_before(params)
  -- 资源维度
  if _.isEmpty(params) then
    logger.warn("熔断参数不能为空！")
    return
  end
  params = cjson.decode(params)
  local res_key = ngx.var.uri
  if params["res_type"] == "project" then
    local matched_route = ngx.ctx.matched_route
    res_key = matched_route and matched_route["type"] or "unknown"
  elseif params["res_type"] == "route" then
    res_key = ngx.var.uri
  end
  -- 初始化熔断信息
  local breaker = circuit_breaker:new(res_key)
  ngx.ctx.circuit_breaker_start_time = ngx.now()
  ngx.ctx.circuit_breaker = breaker
  -- 检查是否需要熔断
  if breaker:check_circuit_breaker() then
    logger.warn("触发熔断，资源为: ", res_key)
    -- 降级
    if params["fallback_strategy"] == FALLBACK_STRATEGY.RETURN_MOCK_DATA then
      -- 返回配置的 mock 数据
      local fallback_config = config.get_config("fallback." .. res_key)
      if not fallback_config then
        ngx.ctx.response:writeln(res_util.serivce_unavailable())
      else
        ngx.ctx.response:writeln(fallback_config["data"])
      end
    else
      ngx.ctx.response:writeln(res_util.serivce_unavailable())
    end
    return false
  end
  return true
end

-- 后置处理
function _M.handle_after()
  local breaker = ngx.ctx.circuit_breaker
  if not breaker then
    return
  end
  -- 记录请求结果
  breaker:record_request()
end

return _M
