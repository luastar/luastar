-- 限流器实现
local ngx = require "ngx"

local _M = {}

-- 限流器配置
_M.rate_limiter = {
  rules = {
    { key = "system", type = "sliding_window", limit = 100, window = 1 },     -- 全局100QPS
    { key = "api:/user/login", type = "token_bucket", rate = 10, burst = 20 } -- 登录接口10RPS
  }
}

return _M
