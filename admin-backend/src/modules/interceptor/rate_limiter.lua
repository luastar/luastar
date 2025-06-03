local ngx = require "ngx"
local config = require "core.config"
local rate_limiter = require "core.rate_limiter"
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
    logger.warn("限流参数不能为空！")
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
  -- 初始化限流器
  local limiter = rate_limiter:new(res_key)
  ngx.ctx.rate_limiter = limiter
  -- 检查是否需要限流
  if limiter:check_limit() then
    logger.warn("触发限流，资源为: ", res_key)
    -- 降级
    if params["fallback_strategy"] == FALLBACK_STRATEGY.RETURN_MOCK_DATA then
      -- 返回配置的 mock 数据
      local fallback_config = config.get_config("fallback." .. res_key)
      if not fallback_config then
        ngx.ctx.response:writeln(res_util.too_many_requests())
      else
        ngx.ctx.response:writeln(fallback_config["data"])
      end
    else
      ngx.ctx.response:writeln(res_util.too_many_requests())
    end
    return false
  end
  return true
end

-- 后置处理
function _M.handle_after(params)
  local limiter = ngx.ctx.rate_limiter
  if limiter then
    limiter:cleanup()
  end
end

return _M
