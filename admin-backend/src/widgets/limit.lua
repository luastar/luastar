--[[
接口限制
1、ip限制
2、频次限制
3、请求次数限制(redis实现)
--]]
local str_util = require "utils.str_util"
local ngx = ngx

local _M = {}

--[[
	限制ip
	local limit_config = {
	    current_ip = "127.0.0.1, 127.0.0.2",
        limit_ip = {"127.0.0.1", "192.168.0.1"}
    }
--]]
function _M.limit_ip(limit_config)
    if _.isEmpty(limit_config)
        or _.isEmpty(limit_config["current_ip"])
        or _.isEmpty(limit_config["limit_ip"]) then
        return false
    end
    logger.info("limit_ip param：", cjson.encode(limit_config))
    for idx_ip, ip in ipairs(limit_config["limit_ip"]) do
        -- 当前ip是否包含逗号
        local is, ie = string.find(limit_config["current_ip"], ",")
        if _.isNil(is) then
            if ip == limit_config["current_ip"] then
                return false
            end
        else
            local current_ip_ary = str_util.split(limit_config["current_ip"], ",")
            for idx_cip, cip in ipairs(current_ip_ary) do
                if ip == str_util.trim(cip) then
                    return false
                end
            end
        end
    end
    return true
end

--[[
	限制访问频次，基于resty.limit.req实现
    local limit_config = {
        {
            key = "aaa:bbb",
            rate = 5,
            burst = 5,
            dict_name = "limit_req_store"
        }
    }
--]]
function _M.limit_req(limit_config)
    if _.isEmpty(limit_config) then
        return false
    end
    logger.info("limit_req param is ：", cjson.encode(limit_config))
    -- 创建频次限制
    local limit_ary = {}
    local limit_key_ary = {}
    local resty_limit_req = require("resty.limit.req")
    for idx, val in ipairs(limit_config) do
        -- limit the requests under 200 req/sec with a burst of 100 req/sec,
        -- that is, we delay requests under 300 req/sec and above 200
        -- req/sec, and reject any requests exceeding 300 req/sec.
        -- local lim, err = limit_req.new("my_limit_req_store", 200, 100)
        local lim, err = resty_limit_req.new(val["dict_name"], val["rate"], val["burst"])
        if lim then
            table.insert(limit_ary, lim)
            table.insert(limit_key_ary, val["key"])
        else
            logger.error("failed to instantiate a resty.limit.req object, dict is ", val["dict_name"], ", err is ", err)
        end
    end
    if _.isEmpty(limit_ary) then
        return false
    end
    -- 多个频次限制
    local limit_state_ary = {}
    local resty_limit_traffic = require("resty.limit.traffic")
    local delay, err = resty_limit_traffic.combine(limit_ary, limit_key_ary, limit_state_ary)
    if not delay then
        if err == "rejected" then
            return true
        end
        logger.error("failed to limit req: ", err)
    else
        if delay >= 0.001 then
            -- the 2nd return value holds  the number of excess requests
            -- per second for the specified key. for example, number 31
            -- means the current request rate is at 231 req/sec for the
            -- specified key.
            logger.info("sleeping ", delay, " sec, states: ", table.concat(limit_state_ary, ", "), ", excess: ", err)
            ngx.sleep(delay)
        end
    end
    return false
end

--[[
    限制访问次数，基于基于resty.limit.count实现，有openresty高版本限制
    local limit_config = {
        {
            key = "",
            time = 120, -- 2分钟
            count = 5,  -- 5次
            dict_name = "limit_count_store"
        }
    }
--]]
function _M.limit_count(limit_config)
    if _.isEmpty(limit_config) then
        return false
    end
    logger.info("limit_count param is ：", cjson.encode(limit_config))
    -- 创建次数限制
    local resty_limit_count = require("resty.limit.count")
    for idx, config in ipairs(limit_config) do
        local lim, err = resty_limit_count.new(config["dict_name"], config["count"], config["time"])
        if not lim then
            logger.error("failed to instantiate a resty.limit.count object: ", err)
        else
            local delay, err = lim:incoming(config["key"], true)
            if not delay then
                if err == "rejected" then
                    return true
                end
                logger.error("failed to limit count: ", err)
            else
                -- the 2nd return value holds the current remaining number
                -- of requests for the specified key.
                logger.info("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", err, "]")
            end
        end
    end
    return false
end

--[[
    限制访问次数，基于redis实现
    local limit_config = {
        {
            key = "",
            time = 120, -- 2分钟
            count = 5  -- 5次
        }
    }
--]]
function _M.limit_count_redis(limit_config, redis_bean_name)
    if _.isEmpty(limit_config) then
        return false
    end
    logger.info("limit_count_redis param is ：", cjson.encode(limit_config))
    local bean_factory = ls_context.get_bean_factory()
    local redis_service = bean_factory:get_bean(redis_bean_name)
    if _.isNil(redis_service) then
        logger.error("limit_count_redis redis service bean is nil.")
        return false
    end
    local redis = redis_service:get_connect()
    for idx, config in ipairs(limit_config) do
        local current_count, current_count_err = redis:incr(config["key"])
        if _.isNil(current_count) then
            logger.error("incr key", config["key"], "error : ", current_count_err)
        else
            logger.info("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", (config["count"] - current_count), "]")
            if current_count == 1 then
                logger.info("expire key ", config["key"], ", time=", config["time"])
                redis:expire(config["key"], config["time"])
            end
            if current_count > config["count"] then
                redis_service:close(redis)
                return true
            end
        end
    end
    redis_service:close(redis)
    return false
end

return _M
