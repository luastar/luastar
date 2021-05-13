--[[
redis操作库
--]]
local Redis = Class("luastar.db.Redis")

local resty_redis = require("resty.redis")

function Redis:init(datasource)
	self.datasource = _.defaults(datasource, {
		host = "127.0.0.1",
		port = "6379",
		auth = nil,
		db_index = 0,
		timeout = 30000,
		max_idle_timeout = 60000,
		pool_size = 50
	})
	ngx.log(ngx.DEBUG, "[Redis:init] datasource : ", cjson.encode(self.datasource))
end

function Redis:getConnect()
	local connect, err = resty_redis:new()
	if not connect then
		ngx.log(ngx.ERR, "[Redis:getConnect] failed to create redis : ", err)
		return nil
	end
	connect:set_timeout(self.datasource["timeout"])
	local ok, err = connect:connect(self.datasource["host"], self.datasource["port"])
	if not ok then
		ngx.log(ngx.ERR, "[Redis:getConnect] failed to connect redis : ", err)
		return nil
	end
	if self.datasource["auth"] then
		connect:auth(self.datasource["auth"])
	end
	if self.datasource["db_index"] >= 0 then
		connect:select(self.datasource["db_index"])
	end
	return connect
end

function Redis:close(connect)
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
		ngx.log(ngx.ERR, "[Redis:close] set keepalive failed : ", err)
	else
		ngx.log(ngx.DEBUG, "[Redis:close] set keepalive ok.")
	end
end

return Redis