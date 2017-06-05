--[[
redis操作库
--]]
local Redis = Class("luastar.db.Redis")

local resty_redis = require("resty.redis")
local db_monitor = require("luastar.db.monitor")

function Redis:init(datasource)
	self.datasource = _.defaults(datasource, {
		host = "127.0.0.1",
		port = "6379",
		auth = nil,
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
	connect:set_timeout(self.datasource.timeout)
	local ok, err = connect:connect(self.datasource.host, self.datasource.port)
	if not ok then
		ngx.log(ngx.ERR, "[Redis:getConnect] failed to connect redis : ", err)
		return nil
	end
	if self.datasource.auth then
		local res, err = connect:auth(self.datasource.auth)
	end
	db_monitor.add("redis_connect")
	return connect
end

function Redis:close(connect)
	db_monitor.sub("redis_connect")
	if connect == nil then
		return
	end
	-- 连接池为空时，直接关闭
	if self.datasource.pool_size <= 0 then
		connect:close()
		return
	end
	-- 将连接放入到连接池中，下次申请直接从连接池中获取
	local ok, err = connect:set_keepalive(self.datasource.max_idle_timeout, self.datasource.pool_size)
	if not ok then
		ngx.log(ngx.ERR, "[Redis:close] set keepalive failed : ", err)
	else
		ngx.log(ngx.DEBUG, "[Redis:close] set keepalive ok.")
	end
end

local commands = {
	"append", "auth", "bgrewriteaof",
	"bgsave", "bitcount", "bitop",
	"blpop", "brpop",
	"brpoplpush", "client", "config",
	"dbsize",
	"debug", "decr", "decrby",
	"del", "discard", "dump",
	"echo",
	"eval", "exec", "exists",
	"expire", "expireat", "flushall",
	"flushdb", "get", "getbit",
	"getrange", "getset", "hdel",
	"hexists", "hget", "hgetall",
	"hincrby", "hincrbyfloat", "hkeys",
	"hlen",
	"hmget", "hmset", "hscan",
	"hset",
	"hsetnx", "hvals", "incr",
	"incrby", "incrbyfloat", "info",
	"keys",
	"lastsave", "lindex", "linsert",
	"llen", "lpop", "lpush",
	"lpushx", "lrange", "lrem",
	"lset", "ltrim", "mget",
	"migrate",
	"monitor", "move", "mset",
	"msetnx", "multi", "object",
	"persist", "pexpire", "pexpireat",
	"ping", "psetex", "psubscribe",
	"pttl",
	"publish", "punsubscribe", "pubsub",
	"quit",
	"randomkey", "rename", "renamenx",
	"restore",
	"rpop", "rpoplpush", "rpush",
	"rpushx", "sadd", "save",
	"scan", "scard", "script",
	"sdiff", "sdiffstore",
	"select", "set", "setbit",
	"setex", "setnx", "setrange",
	"shutdown", "sinter", "sinterstore",
	"sismember", "slaveof", "slowlog",
	"smembers", "smove", "sort",
	"spop", "srandmember", "srem",
	"sscan",
	"strlen", --[[ "subscribe", ]] "sunion",
	"sunionstore", "sync", "time",
	"ttl",
	"type", "unsubscribe", "unwatch",
	"watch", "zadd", "zcard",
	"zcount", "zincrby", "zinterstore",
	"zrange", "zrangebyscore", "zrank",
	"zrem", "zremrangebyrank", "zremrangebyscore",
	"zrevrange", "zrevrangebyscore", "zrevrank",
	"zscan",
	"zscore", "zunionstore", "evalsha"
}

for i = 1, #commands do
	local cmd = commands[i]
	Redis[cmd] = function(self, ...)
		local connect = self:getConnect()
		if not connect then
			return nil
		end
		-- exec cmd
		local res, err = connect[cmd](connect, ...)
		-- close
		self:close(connect)
		return res, err
	end
end

function Redis:subscribe(channel)
	local connect = self:getConnect()
	if not connect then
		return nil
	end
	local res, err = connect:subscribe(channel)
	if not res then
		return nil, err
	end
	local function do_read_func(do_read)
		if do_read == nil or do_read == true then
			res, err = connect:read_reply()
			if not res then
				return nil, err
			end
			return res
		end
		connect:unsubscribe(channel)
		self:close(connect)
		return
	end

	return do_read_func
end

return Redis