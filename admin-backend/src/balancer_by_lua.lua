local ngx = require "ngx"
local balancer = require "ngx.balancer"

-- 使用 ngx.ctx 存放模块，再从字典中动态取服务器配置
local ok, err = balancer.set_current_peer("127.0.0.1", 8002)
if not ok then
    logger.error("failed to set the current peer: ", err)
    return ngx.exit(500)
end
