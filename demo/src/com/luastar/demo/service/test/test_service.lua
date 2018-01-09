--[[

--]]
local testService = Class()
local table_util = require("luastar.util.table")

function testService:init(redis_util)
    self.redis_util = redis_util
end

--[[
-- 根据uid获取用户信息
--]]
function testService:getUserInfo(uid)
    if _.isEmpty(uid) then
        return nil
    end
    local redis = self.redis_util:getConnect()
    local userinfo = table_util.array_to_hash(redis:hgetall("user:info:" .. uid))
    self.redis_util:close(redis)
    if _.isEmpty(userinfo) then
        ngx.log(logger.e("userinfo is empty, uid=", uid))
        return nil
    end
    ngx.log(logger.i(cjson.encode(userinfo)))
    return userinfo
end

return testService
