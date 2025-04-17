--[===[
mysql操作库
insert res
{
"insert_id": 170,
"server_status": 2,
"warning_count": 0,
"affected_rows": 1
}

update res
{
"insert_id": 0,
"server_status": 2,
"warning_count": 0,
"affected_rows": 1,
"message": "(Rows matched: 1 Changed: 1 Warnings: 0"
}

select res
[{
"AREA_NAME": "中国",
"AREA_STATUS": 1,
"AREA_CODE": "CN",
"ID": 1,
"AREA_LEVEL": 1,
"PARENT_AREA_CODE": null,
"UPDATE_TIME": null,
"CREATE_TIME": null
},
{
"AREA_NAME": "北京市",
"AREA_STATUS": 1,
"AREA_CODE": "110000",
"ID": 2,
"AREA_LEVEL": 2,
"PARENT_AREA_CODE": "CN",
"UPDATE_TIME": null,
"CREATE_TIME": null
}]
--]===]
local resty_mysql = require("resty.mysql")
local str_util = require("utils.str_util")
local try_util = require("utils.try_util")

local _M = {}
local mt = { __index = _M }

function _M:new(datasource)
	logger.debug("[Mysql:init] datasource : ", cjson.encode(datasource))
	local instance = {
		datasource = _.defaults(datasource, {
			host = "127.0.0.1",
			port = "3306",
			database = "",
			user = "",
			password = "",
			charset = "utf8",
			max_packet_size = 1024 * 1024,
			timeout = 10000,
			pool_size = 64,
			max_idle_timeout = 60000,
		})
	}
	return setmetatable(instance, mt)
end

function _M:get_connect()
	-- 创建数据库实例
	local db, err = resty_mysql:new()
	if not db then
		logger.error("[Mysql:get_connect] failed to instantiate mysql : ", err)
		return nil
	end
	-- 设置超时时间
	db:set_timeout(self.datasource["timeout"])
	-- 获取连接
	local ok, err, errcode, sqlstate = db:connect(self.datasource)
	if not ok then
		logger.error("[Mysql:get_connect] failed to connect mysql : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
		db:close()
		return nil
	end
	return db
end

function _M:query(sql, nrows)
	-- 获取连接
	local connect = self:get_connect()
	if not connect then
		return nil, "failed to get mysql connect."
	end
	-- 执行 SQL 语句
	local res, err, errcode, sqlstate = connect:query(sql, nrows)
	self:close(connect)
	return res, err, errcode, sqlstate
end

function _M:multi_query(sql)
	-- 获取连接
	local connect = self:get_connect()
	if not connect then
		return nil, "failed to get mysql connect."
	end
	-- 执行 SQL 语句
	local result = {}
	local res, err, errcode, sqlstate = connect:query(sql)
	table.insert(result, { res = res, err = err, errcode = errcode, sqlstate = sqlstate })
	if not res then
		self:close(connect)
		return result
	end
	while err == "again" do
		res, err, errcode, sqlstate = connect:read_result()
		table.insert(result, { res = res, err = err, errcode = errcode, sqlstate = sqlstate })
		if not res then
			self:close(connect)
			return result
		end
	end
	self:close(connect)
	return result
end

function _M:multi_query_transaction(sql_array)
	-- 参数校验
	if not _.isArray(sql_array) then
		return nil, "param must be an array."
	end
	-- 获取连接
	local connect = self:get_connect()
	if not connect then
		return nil, "failed to get mysql connect."
	end
	-- 开始事务
	logger.info("[Mysql:multi_query_transaction] start transaction.")
	local res_st, err_st, errcode_st, sqlstate_st = connect:query("START TRANSACTION;")
	if not res_st then
		logger.error("[Mysql:multi_query_transaction] start transaction failed : err = ", err_st, ", errcode = : ", errcode_st, ", sqlstate = ", sqlstate_st)
		self:close(connect)
		return nil, "start transaction error."
	end
	-- 执行 SQL 语句
	local result = {}
	for i, sql in ipairs(sql_array) do
		-- 以分号结尾
		if not str_util.end_with(sql, ";") then sql = sql .. ";" end
		-- 逐条执行
		local res, err, errcode, sqlstate = connect:query(sql)
		table.insert(result, { res = res, err = err, errcode = errcode, sqlstate = sqlstate })
		-- 执行失败，回滚
		if not res then
			logger.info("[Mysql:multi_query_transaction] start rollback.")
			local res_rb, err_rb, errcode_rb, sqlstate_rb = connect:query("ROLLBACK;")
			if not res_rb then
				logger.error("[Mysql:multi_query_transaction] rollback failed : err = ", err_rb, ", errcode = ", errcode_rb, ", sqlstate = ", sqlstate_rb)
			end
			self:close(connect)
			return result
		end
	end
	-- commit
	logger.info("[Mysql:multi_query_transaction] start commit.")
	local res_commit, err_commit, errcode_commit, sqlstate_commit = connect:query("COMMIT;")
	if not res_commit then
		logger.error("[Mysql:multi_query_transaction] commit failed : err = ", err_commit, ", errcode = ", errcode_commit, ", sqlstate = ", sqlstate_commit)
	end
	self:close(connect)
	return result
end

function _M:close(connect)
	if connect == nil then
		return
	end
	if self.datasource["pool_size"] <= 0 then
		connect:close()
		return
	end
	-- 将连接放入到连接池中，下次申请直接从连接池中获取
	local ok, err = connect:set_keepalive(self.datasource["max_idle_timeout"], self.datasource["pool_size"])
	if not ok then
		logger.error("[Mysql:close] set keepalive failed : ", err)
	else
		logger.info("[Mysql:close] set keepalive ok.")
	end
end

return _M
