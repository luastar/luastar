--[[
    用户角色服务类
--]]
local UserRoleRelationService = Class()

local sql_util = require("luastar.util.sql")

function UserRoleRelationService:init()
	self.queryCondition = {
		[[ID=#{id}]],
		[[and USER_ID=#{userId}]],
		[[and ROLE_ID=#{roleId}]]
	}
end

function UserRoleRelationService:userRoleRelationResultMap(result)
	if _.isEmpty(result) then
		return nil
	end
	return {
		id = result["ID"],
		userId = result["USER_ID"],
		roleId = result["ROLE_ID"]
	}
end

function UserRoleRelationService:insert(userRole)
	local sql_table = {
		sql = [[
            insert into SYS_USER_ROLE_RELATION (
				USER_ID,ROLE_ID
			) values (
				#{userId},#{roleId}
			)
        ]]
	}
	local sql = sql_util.getsql(sql_table, userRole)
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
	userRole["id"] = res["insert_id"]
	return userRole["id"]
end

function UserRoleRelationService:deleteByUserId(userId)
	local sql_table = {
		sql = [[
            delete from SYS_USER_ROLE_RELATION
        	where USER_ID=#{userId}
        ]]
	}
	local sql = sql_util.getsql(sql_table, { userId = userId })
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
	return 0
end

function UserRoleRelationService:getUserRoleRelationList(data)
	if data == nil then
		data = {}
	end
	local sql_table = {
		sql = [[
            select * from SYS_USER_ROLE_RELATION
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
		return self:userRoleRelationResultMap(v)
	end)
end

return UserRoleRelationService
