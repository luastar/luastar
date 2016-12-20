--[[

--]]
local _M = {}

local table_util = require("luastar.util.table")

function _M.redis(request, response)
    local uid = 10001
    local beanFactory = luastar_context.getBeanFactory()
    local redis_util = beanFactory:getBean("redis")
    local redis = redis_util:getConnect()
    local userinfo = table_util.array_to_hash(redis:hgetall("user:info:" .. uid))
    redis_util:close(redis)
    response:writeln(cjson.encode(userinfo))
end

return _M