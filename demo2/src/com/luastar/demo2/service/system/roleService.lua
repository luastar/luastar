--[[
    角色服务类
--]]
local RoleService = Class()

local sql_util = require("luastar.util.sql")

function RoleService:init()
	self.queryCondition = {
		[[ID=#{id}]],
		[[and ROLE_NAME=#{roleName}]],
		[[and CREATED_TIME=#{createdTime}]],
		[[and UPDATED_TIME=#{updatedTime}]],
		[[and (
			and (ROLE_NAME like concat('%',#{keyword},'%'))
		)]]
	}
end

function RoleService:roleResultMap(result)
	if _.isEmpty(result) then
		return nil
	end
	return {
		id = result["ID"],
		roleName = result["ROLE_NAME"],
		createdTime = result["CREATED_TIME"],
		updateTime = result["UPDATED_TIME"]
	}
end

function RoleService:getRoleById(id)
	if _.isEmpty(id) then
		return nil
	end
	local sql_table = {
		sql = [[
            select * from SYS_ROLE
            where ID = #{id}
        ]]
	}
	local data = { id = id }
	local sql = sql_util.getsql(sql_table, data)
	local beanFactory = luastar_context.getBeanFactory()
	local mysql_util = beanFactory:getBean("mysql")
	local mysql = mysql_util:getConnect()
	local res, err, errno, sqlstate = mysql:query(sql)
	ngx.log(logger.i(cjson.encode({
		sql = sql,
		res = res,
		err = err,
		errno = errno,
		sqlstate = sqlstate
	})))
	mysql_util:close(mysql)
	if _.isEmpty(res) then
		return nil
	end
	return self:roleResultMap(res[1])
end

function RoleService:countRole(data)
	if data == nil then
		data = {}
	end
	local sql_table = {
		sql = [[
            select count(*) num
            from SYS_ROLE
            @{where}
        ]],
		where = self.queryCondition
	}
	local sql = sql_util.getsql(sql_table, data)
	local beanFactory = luastar_context.getBeanFactory()
	local mysql_util = beanFactory:getBean("mysql")
	local mysql = mysql_util:getConnect()
	local res, err, errno, sqlstate = mysql:query(sql)
	ngx.log(logger.i(cjson.encode({
		sql = sql,
		res = res,
		err = err,
		errno = errno,
		sqlstate = sqlstate
	})))
	mysql_util:close(mysql)
	if _.isEmpty(res) then
		return 0
	end
	return tonumber(res[1]["num"])
end

function RoleService:getRoleList(data)
	if data == nil then
		data = {}
	end
	local sql_table = {
		sql = [[
            select * from SYS_ROLE
			@{where}
			order by ID desc
			@{limit}
        ]],
		where = self.queryCondition,
		limit = {
			start = "#{start}",
			limit = "#{limit}"
		}
	}
	local sql = sql_util.getsql(sql_table, data)
	local beanFactory = luastar_context.getBeanFactory()
	local mysql_util = beanFactory:getBean("mysql")
	local mysql = mysql_util:getConnect()
	local res, err, errno, sqlstate = mysql:query(sql)
	ngx.log(logger.i(cjson.encode({
		sql = sql,
		res = res,
		err = err,
		errno = errno,
		sqlstate = sqlstate
	})))
	mysql_util:close(mysql)
	if _.isEmpty(res) then
		return nil
	end
	return _.mapArray(res, function(i, v)
		return self:roleResultMap(v)
	end)
end

return RoleService
