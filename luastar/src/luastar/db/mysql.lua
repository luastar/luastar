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
local Mysql = Class("luastar.db.Mysql")

local resty_mysql = require("resty.mysql")
local db_monitor = require("luastar.db.monitor")

function Mysql:init(datasource)
	self.datasource = _.defaults(datasource, {
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
	ngx.log(ngx.DEBUG, "[Mysql:init] datasource : ", cjson.encode(self.datasource))
end

function Mysql:getConnect()
	local connect, err = resty_mysql:new()
	if not connect then
		ngx.log(ngx.ERR, "[Mysql:initConnect] failed to create mysql : ", err)
		return nil
	end
	connect:set_timeout(self.datasource.timeout)
	local ok, err, errno, sqlstate = connect:connect(self.datasource)
	if not ok then
		ngx.log(ngx.ERR, "[Mysql:getConnect] failed to connect mysql : ", err)
		return nil
	end
	-- set charset
	local res, err, errno, sqlstate = connect:query("SET NAMES " .. self.datasource.charset)
	if not res then
		ngx.log(ngx.ERR, "[Mysql:getConnect] set charset fail : ", err)
	end
	db_monitor.add("mysql_connect")
	return connect
end

function Mysql:query(sql, nrows)
	local connect = self:getConnect()
	if not connect then
		ngx.log(ngx.ERR, "[Mysql:query] failed to get mysql connect.")
		return nil
	end
	-- exec sql
	local res, err, errno, sqlstate = connect:query(sql, nrows)
	self:close(connect)
	return res, err, errno, sqlstate
end

function Mysql:close(connect)
	db_monitor.sub("mysql_connect")
	if connect == nil then
		return
	end
	if self.datasource.pool_size <= 0 then
		connect:close()
		return
	end
	-- put it into the connection pool of size 100,
	-- with 10 seconds max idle timeout
	local ok, err = connect:set_keepalive(self.datasource.max_idle_timeout,
		self.datasource.pool_size)
	if not ok then
		ngx.log(ngx.ERR, "[Mysql:close] set keepalive failed : ", err)
	else
		ngx.log(ngx.DEBUG, "[Mysql:close] set keepalive ok.")
	end
end

return Mysql

