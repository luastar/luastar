--[[

--]]
local _M = {}

local table_util = require("luastar.util.table")

function _M.redis(request, response)
    local uid = 10001
    local bean_factory = luastar_context.get_bean_factory()
    local redis_util = bean_factory:get_bean("redis")
    local redis = redis_util:get_connect()
    local userinfo = table_util.array_to_hash(redis:hgetall("user:info:" .. uid))
    redis_util:close(redis)
    response:writeln(cjson.encode(userinfo))
end

return _M