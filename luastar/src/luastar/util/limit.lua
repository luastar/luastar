--[[
接口限制
1、ip限制
2、请求次数限制(redis实现)
3、频次限制
--]]

local _M = {}

local str_util = require("luastar.util.str")

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
        -- ngx.log(logger.i("limit_ip param is empty."))
        return false
    end
    -- ngx.log(logger.i("limit_ip param：", cjson.encode(limit_config)))
    for idx_ip, ip in ipairs(limit_config["limit_ip"]) do
        -- 当前ip是否包含逗号
        local is, ie = string.find(limit_config["current_ip"], ",")
        if is == nil then
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
    ngx.log(logger.i("=====limit_ip success====="))
    return true
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
        -- ngx.log(logger.i("limit_count param is empty."))
        return false
    end
    -- ngx.log(logger.i("limit_count param is ：", cjson.encode(limit_config)))
    -- 创建次数限制
    local resty_limit_count = require("resty.limit.count")
    for idx, config in ipairs(limit_config) do
        local lim, err = resty_limit_count.new(config["dict_name"], config["count"], config["time"])
        if not lim then
            ngx.log(logger.e("failed to instantiate a resty.limit.count object: ", err))
        else
            local delay, err = lim:incoming(config["key"], true)
            if not delay then
                if err == "rejected" then
                    ngx.log(logger.e("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", 0, "]"))
                    ngx.log(logger.i("=====limit_count success====="))
                    return true
                else
                    ngx.log(logger.e("failed to limit count: ", err))
                end
            else
                -- the 2nd return value holds the current remaining number of requests for the specified key.
                ngx.log(logger.e("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", err, "]"))
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
        -- ngx.log(logger.i("limit_count_redis param is empty."))
        return false
    end
    -- ngx.log(logger.i("limit_count_redis param is :", cjson.encode(limit_config)))
    local beanFactory = luastar_context.getBeanFactory()
    local redis_service = beanFactory:getBean(redis_bean_name)
    if _.isNil(redis_service) then
        ngx.log(logger.e("limit_count_redis redis service bean is nil."))
        return false
    end
    local redis = redis_service:getConnect()
    for idx, config in ipairs(limit_config) do
        local current_count = redis:get(config["key"])
        if _.isEmpty(current_count) then
            current_count = 1
            ngx.log(logger.i("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", (config["count"] - current_count), "]"))
            -- 用redis事务执行，保证incr和expire同时生效
            local multi_ok, multi_err = redis:multi()
            if not multi_ok then
                ngx.log(logger.e("multi error:", multi_err))
            else
                redis:incr(config["key"]) -- 访问次数+1
                redis:expire(config["key"], config["time"]) -- 过期时间
                local exec_ans, exec_err = redis:exec()
                ngx.log(logger.i("incr and expire key ans=", cjson.encode(exec_ans), ", err=", exec_err))
            end
        else
            -- 访问次数+1
            local incr_ok, incr_err = redis:incr(config["key"])
            ngx.log(logger.i("incr_ok=", incr_ok, ", incr_err=", incr_err))
            current_count = tonumber(current_count) + 1
            ngx.log(logger.i("key[", config["key"], "] limit count [", config["count"], "] per [", config["time"], "] seconds remaining [", (config["count"] - current_count), "]"))
            if current_count > config["count"] then
                ngx.log(logger.i("=====limit_count_redis success====="))
                redis_service:close(redis)
                return true
            end
        end
    end
    redis_service:close(redis)
    return false
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
        -- ngx.log(logger.i("limit_req param is empty."))
        return false
    end
    -- ngx.log(logger.i("limit req param is ：", cjson.encode(limit_config)))
    -- 创建频次限制
    local limit_ary = {}
    local limit_key_ary = {}
    local resty_limit_req = require("resty.limit.req")
    _.eachArray(limit_config, function(i, v)
        local lim, err = resty_limit_req.new(v["dict_name"], v["rate"], v["burst"])
        if lim then
            table.insert(limit_ary, lim)
            table.insert(limit_key_ary, v["key"])
        else
            ngx.log(logger.e("failed to instantiate a resty.limit.req object, dict is ", v["dict_name"], ", err is ", err))
        end
    end)
    if _.isEmpty(limit_ary) then
        ngx.log(logger.i("all limit_req create fail."))
        return false
    end
    -- 多个频次限制
    local limit_state_ary = {}
    local resty_limit_traffic = require("resty.limit.traffic")
    local delay, err = resty_limit_traffic.combine(limit_ary, limit_key_ary, limit_state_ary)
    if not delay then
        if err == "rejected" then
            ngx.log(logger.i("=====limit_req success====="))
            return true
        else
            ngx.log(logger.e("failed to limit traffic: ", err))
        end
    else
        ngx.log(logger.i("sleeping ", delay, " sec, states: ", table.concat(limit_state_ary, ", ")))
        if delay >= 0.001 then
            -- ngx.sleep(delay)
        end
    end
    return false
end

return _M
