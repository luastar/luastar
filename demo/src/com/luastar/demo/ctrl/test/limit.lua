--[[
-- 访问限制
--]]

local _M = {}

local str_util = require("luastar.util.str")
local limit_util = require("luastar.util.limit")
local json_util = require("com.luastar.demo.util.json")

--[[
    limit
--]]
function _M.limit(request)
    local limit_config = luastar_config.getConfig("limit_config")
    -- uid
    local uid = _.ifEmpty(request:get_header("uid"), "")
    local uri = request.uri
    ngx.log(logger.i("uid=", uid, ", uri=", uri))
    -- ip限制
     local limit_config_ip = { current_ip = request:get_ip() }
    if not _.isEmpty(limit_config[uid]) then
        limit_config_ip["limit_ip"] = limit_config[uid]["limit_ip"]
    end
    local is_limit = limit_util.limit_ip(limit_config_ip)
    if is_limit then
        return is_limit, json_util.fail("ip受限制")
    end
    -- 请求数量限制
    local limit_config_count = limit_config["default"]["limit_count"]
    if not _.isEmpty(limit_config[uid])
            and not _.isEmpty(limit_config[uid]["limit_count"]) then
        limit_config_count = limit_config[uid]["limit_count"]
    end
    local limit_config_count2 = {}
    _.eachArray(limit_config_count, function(idx, val)
        -- 是否满足配置条件
        if str_util.uri_is_macth(uri, val["url"][1], val["url"][2]) then
            table.insert(limit_config_count2, {
                key = uid .. uri,
                time = val["time"],
                count = val["count"]
            })
        end
    end)
    local is_limit = limit_util.limit_count_redis(limit_config_count2, "redis")
    if is_limit then
        return is_limit, json_util.fail("请求次数受限制")
    end
    -- 频次限制
    local limit_config_req1 = limit_config["default"]["limit_req"]
    if not _.isEmpty(limit_config[uid])
            and not _.isEmpty(limit_config[uid]["limit_req"]) then
        limit_config_req1 = limit_config[uid]["limit_req"]
    end
    local limit_config_req2 = {}
    _.eachArray(limit_config_req1, function(idx, val)
        -- 是否满足配置条件
        if str_util.uri_is_macth(uri, val["url"][1], val["url"][2]) then
            table.insert(limit_config_req2, {
                key = uid .. uri,
                dict_name = limit_config["dict_limit_req"],
                rate = val["rate"],
                burst = val["burst"]
            })
        end
    end)
    local is_limit = limit_util.limit_req(limit_config_req2)
    if is_limit then
        return is_limit, json_util.fail("请求频次受限制")
    end
    return false
end

return _M