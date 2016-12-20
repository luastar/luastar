--[[
    系统用户服务类
--]]
local UserService = Class()

local sql_util = require("luastar.util.sql")
local date_util = require("luastar.util.date")

function UserService:init()
	self.queryCondition = {
		[[ID=#{id}]],
		[[and LOGIN_NAME=#{loginName}]],
		[[and PAZZWORD=#{pazzword}]],
		[[and USER_NAME=#{userName}]],
		[[and IS_EFFECTIVE=#{isEffective}]],
		[[and CREATED_TIME=#{createdTime}]],
		[[and UPDATED_TIME=#{updatedTime}]],
		[[and (
			LOGIN_NAME like concat('%',#{keyword},'%') or USER_NAME like concat('%',#{keyword},'%')
		)]]
	}
end

function UserService:getEmptyUser()
	return {
		id = 0,
		loginName = "",
		pazzword = "",
		userName = "",
		isEffective = 1,
		createdTime = "",
		updateTime = ""
	}
end

function UserService:userResultMap(result)
	if _.isEmpty(result) then
		return nil
	end
	return {
		id = result["ID"],
		loginName = result["LOGIN_NAME"],
		pazzword = result["PAZZWORD"],
		userName = result["USER_NAME"],
		isEffective = result["IS_EFFECTIVE"],
		createdTime = result["CREATED_TIME"],
		updateTime = result["UPDATED_TIME"]
	}
end

function UserService:insert(user)
	local sql_table = {
		sql = [[
            insert into SYS_USER (
                LOGIN_NAME,PAZZWORD,USER_NAME,IS_EFFECTIVE,CREATED_TIME,UPDATED_TIME
            ) values (
                #{loginName},#{pazzword},#{userName},#{isEffective},#{createdTime},#{updatedTime}
            )
        ]]
	}
	user["createdTime"] = date_util.get_time()
	local sql = sql_util.getsql(sql_table, user)
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
	user["id"] = res["insert_id"]
	return user["id"]
end

function UserService:update(user)
	local sql_table = {
		sql = [[
            update SYS_USER
            @{set}
            where ID=#{id}
        ]],
		set = {
			[[LOGIN_NAME=#{loginName}]],
			[[PAZZWORD=#{pazzword}]],
			[[USER_NAME=#{userName}]],
			[[IS_EFFECTIVE=#{isEffective}]],
			[[CREATED_TIME=#{createdTime}]],
			[[UPDATED_TIME=#{updatedTime}]]
		}
	}
	local sql = sql_util.getsql(sql_table, user)
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
	return res["affected_rows"]
end

function UserService:getUserById(id)
	if _.isEmpty(id) then
		return nil
	end
	local sql_table = {
		sql = [[
            select * from SYS_USER
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
	return self:userResultMap(res[1])
end

function UserService:getUserByName(loginName)
	if _.isEmpty(loginName) then
		return nil
	end
	local sql_table = {
		sql = [[
            select * from SYS_USER
            where LOGIN_NAME = #{loginName}
            order by ID desc
            limit 1
        ]]
	}
	local data = { loginName = loginName }
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
	return self:userResultMap(res[1])
end

function UserService:countUser(data)
	if data == nil then
		data = {}
	end
	local sql_table = {
		sql = [[
            select count(*) num
            from SYS_USER
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

function UserService:getUserList(data)
	if data == nil then
		data = {}
	end
	local sql_table = {
		sql = [[
            select * from SYS_USER
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
		return self:userResultMap(v)
	end)
end

function UserService:existUser(userId, loginName)
	if _.isEmpty(loginName) then
		return true
	end
	local userList = self:getUserList({ loginName = loginName })
	if _.isEmpty(userList) then
		return false
	end
	-- 如果新增，有记录则存在
	if _.isEmpty(userId) or tonumber(userId) == 0 then
		return true
	end
	-- 如果是修改，则多于一条记录则存在
	if #userList > 1 then
		return true
	end
	-- 如果是修改，只有一条记录且ID与自己不同，则存在
	if userList[1]["id"] ~= tonumber(userId) then
		return true;
	end
	return false;
end

return UserService
