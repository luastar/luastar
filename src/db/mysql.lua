--[===[
mysql操作库
insert res
{"insert_id":170,"server_status":2,"warning_count":0,"affected_rows":1}

update res
{"insert_id":0,"server_status":2,"warning_count":0,"affected_rows":1,"message":"(Rows matched: 1  Changed: 1  Warnings: 0"}

select res
note null value type is userdata
[{"AREA_NAME":"中国","AREA_STATUS":1,"AREA_CODE":"CN","ID":1,"AREA_LEVEL":1,"PARENT_AREA_CODE":null,"UPDATE_TIME":null,"CREATE_TIME":null},{"AREA_NAME":"北京市","AREA_STATUS":1,"AREA_CODE":"110000","ID":2,"AREA_LEVEL":2,"PARENT_AREA_CODE":"CN","UPDATE_TIME":null,"CREATE_TIME":null}]

--]===]
local RestyMysql = require("resty.mysql")
local str_util = require("utils.str_util")

local _M = {}
local mt = { __index = _M }

function _M:new(datasource)
	ngx.log(ngx.DEBUG, "[Mysql:init] datasource : ", cjson.encode(datasource))
	local instance = {
		datasource = _.defaults(datasource, {
			host = "127.0.0.1",
			port = "3306",
			database = "",
			user = "",
			password = "",
			timeout = 30000,
			max_idle_timeout = 60000,
			pool_size = 50,
			charset = "utf8"
		})
	}
	return setmetatable(instance, mt)
end

function _M:get_connect()
	local mysql, err = RestyMysql:new()
	if not mysql then
		ngx.log(ngx.ERR, "[Mysql:get_connect] failed to connect mysql : ", err)
		return nil
	end
	mysql:set_timeout(self.datasource["timeout"])
	local ok, err, errno, sqlstate = mysql:connect(self.datasource)
	if not ok then
		ngx.log(ngx.ERR, "[Mysql:get_connect] failed to connect mysql : ", err)
		return nil
	end
	-- set charset
	local res, err, errno, sqlstate = mysql:query("SET NAMES " .. self.datasource["charset"])
	if not res then
		ngx.log(ngx.ERR, "[Mysql:get_connect] set charset fail : ", err)
	end
	return mysql
end

function _M:query(sql, nrows)
	local connect = self:get_connect()
	if not connect then
		ngx.log(ngx.ERR, "[Mysql:query] failed to get mysql connect.")
		return nil, "failed to get mysql connect."
	end
	-- exec sql
	local res, err, errno, sqlstate = connect:query(sql, nrows)
	self:close(connect)
	return res, err, errno, sqlstate
end

function _M:query_transaction(sqlArray)
	if not _.isArray(sqlArray) then
		ngx.log(ngx.ERR, "[Mysql:query_transaction] sqlArray must be an array.")
		return nil, "sqlArray must be an array."
	end
	local connect = self:get_connect()
	if not connect then
		ngx.log(ngx.ERR, "[Mysql:query] failed to get mysql connect.")
		return nil, "failed to get mysql connect."
	end
	-- start transaction
	local res_start_transaction, err_start_transaction, errno_start_transaction, sqlstate_start_transaction = connect:query("START TRANSACTION;")
	if _.isEmpty(res_start_transaction) then
		ngx.log(ngx.ERR, "[Mysql:query_transaction] start transaction error.")
		self:close(connect)
		return nil, "start transaction error."
	end
	-- exec sql
	local result = {}
	for index, sql in ipairs(sqlArray) do
		-- 多条sql以分号结尾
		if not str_util.end_with(sql, ";") then sql = sql .. ";" end
		-- 逐条执行sql
		local res, err, errno, sqlstate = connect:query(sql)
		table.insert(result, { res = res, err = err, errno = errno, sqlstate = sqlstate })
		-- 执行有异常，回滚
		if _.isEmpty(res) then
			local res_rollback, err_rollback, errno_rollback, sqlstate_rollback = connect:query("ROLLBACK;")
			if _.isEmpty(res_rollback) then
				ngx.log(ngx.ERR, "[Mysql:query_transaction] rollback error.")
			else
				ngx.log(ngx.INFO, "[Mysql:query_transaction] transaction rollback.")
			end
			self:close(connect)
			return result
		end
	end
	-- commit
	local res_commit, err_commit, errno_commit, sqlstate_commit = connect:query("COMMIT;")
	if _.isEmpty(res_commit) then
		ngx.log(ngx.ERR, "[Mysql:query_transaction] commit error.")
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
	-- put it into the connection pool of size 100,
	-- with 10 seconds max idle timeout
	local ok, err = connect:set_keepalive(self.datasource["max_idle_timeout"], self.datasource["pool_size"])
	if not ok then
		ngx.log(ngx.ERR, "[Mysql:close] set keepalive failed : ", err)
	else
		ngx.log(ngx.DEBUG, "[Mysql:close] set keepalive ok.")
	end
end

return _M

