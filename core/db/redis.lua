--[[
redis操作库
--]]
local resty_redis = require("resty.redis")

local _M = {}
local mt = { __index = _M }

function _M:new(datasource)
	logger.debug("[Redis:init] datasource : ", cjson.encode(datasource))
	local instance = {
		datasource = _.defaults(datasource, {
			host = "127.0.0.1",
			port = "6379",
			auth = nil,
			db_index = 0,
			timeout = 10000,
			max_idle_timeout = 60000,
			pool_size = 64
		})
	}
	return setmetatable(instance, mt)
end

function _M:get_connect()
	-- 创建实例
	local redis, err = resty_redis:new()
	if not redis then
		logger.error("[Redis:get_connect] failed to create redis : ", err)
		return nil
	end
	-- 设置超时时间
	redis:set_timeout(self.datasource["timeout"])
	-- 获取连接
	local ok, err = redis:connect(self.datasource["host"], self.datasource["port"], { pool_size = self.datasource["pool_size"] })
	if not ok then
		logger.error("[Redis:get_connect] failed to connect redis : ", err)
		return nil
	end
	-- 认证
	if self.datasource["auth"] then
		redis:auth(self.datasource["auth"])
	end
	-- 选择数据库
	if self.datasource["db_index"] >= 0 then
		redis:select(self.datasource["db_index"])
	end
	return redis
end

function _M:close(connect)
	if connect == nil then
		return
	end
	-- 连接池为空时，直接关闭
	if self.datasource["pool_size"] <= 0 then
		connect:close()
		return
	end
	-- 将连接放入到连接池中，下次申请直接从连接池中获取
	local ok, err = connect:set_keepalive(self.datasource["max_idle_timeout"], self.datasource["pool_size"])
	if not ok then
		logger.error("[Redis:close] set keepalive failed : ", err)
	else
		logger.info("[Redis:close] set keepalive ok.")
	end
end

return _M
