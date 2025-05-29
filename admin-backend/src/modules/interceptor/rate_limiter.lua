-- 限流器拦截器
local ngx = require "ngx"

local _M = {}

-- 前置处理
function _M.handle_before(params)
  return true
end

-- 后置处理
function _M.handle_after(params)

end

return _M
