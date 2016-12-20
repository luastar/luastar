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
    local result_table = {}
    local beanFactory = luastar_context.getBeanFactory()
    local mysql_util = beanFactory:getBean("mysql")
    local mysql = mysql_util:getConnect()
    -- start transaction
    local sql1 = "START TRANSACTION;"
    local res1, err1, errno1, sqlstate1 = mysql:query(sql1)
    table.insert(result_table, { sql1 = sql1, res1 = res1, err1 = err1 })
    -- right sql
    local sql2 = "update SYS_USER set USER_NAME='管理员' where ID=1;"
    local res2, err2, errno2, sqlstate2 = mysql:query(sql2)
    table.insert(result_table, { sql2 = sql2, res2 = res2, err2 = err2 })
    -- error sql (table not exist)
    local sql3 = "update SYS_USER_1 set USER_NAME=3 where ID=1;"
    local res3, err3, errno3, sqlstate3 = mysql:query(sql3)
    table.insert(result_table, { sql3 = sql3, res3 = res3, err3 = err3 })
    if not _.isEmpty(res3) then
        -- commit
        local sql4 = "COMMIT;"
        local res4, err4, errno4, sqlstate4 = mysql:query(sql4)
        table.insert(result_table, { sql4 = sql4, res4 = res4, err4 = err4 })
    else
        -- rollback
        local sql5 = "ROLLBACK;"
        local res5, err5, errno5, sqlstate5 = mysql:query(sql5)
        table.insert(result_table, { sql5 = sql5, res5 = res5, err5 = err5 })
    end
    mysql_util:close(mysql)
    response:writeln(cjson.encode(result_table))
end

return _M