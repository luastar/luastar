--[[

--]]

local _M = {}

local sql_util = require("luastar.util.sql")

function _M.mysql(request, response)
    local name = request:get_arg("name") or ""
    local sql_table = {
        sql = [[
            select * from SYS_USER
            @{where}
            order by ID desc
            limit #{start},#{limit}
        ]],
        where = {
            "LOGIN_NAME = #{loginName}",
            [[
              and USER_NAME like concat('%',#{userName},'%')
            ]]
        }
    }
    local data = { userName = name, start = 0, limit = 10 }
    local sql = sql_util.getsql(sql_table, data)
    local beanFactory = luastar_context.getBeanFactory()
    local mysql_util = beanFactory:getBean("mysql")
    local mysql = mysql_util:getConnect()
    local res, err, errno, sqlstate = mysql:query(sql)
    mysql_util:close(mysql)
    response:writeln(cjson.encode({
        sql = sql,
        res = res,
        err = err,
        errno = errno,
        sqlstate = sqlstate
    }))
end

function _M.transaction(request, response)
    local beanFactory = luastar_context.getBeanFactory()
    local mysql_util = beanFactory:getBean("mysql")
    local sqlArray = {
        "update SYS_USER set USER_NAME='管理员1' where ID=1",
        "update SYS_USER set USER_NAME_A='管理员2' where ID=1" -- USER_NAME_A not exists
    }
    local result_table = mysql_util:queryTransaction(sqlArray)
    response:writeln(cjson.encode(result_table))
end

return _M