--[===[
sql_table = {
  sql = [[
    update SYS_USER @{set} @{where}
  ]],
  set = {
    "USER_NAME = #{userName}",
    "UPDATED_TIME = #{updatedTime}"
  },
  where = {
    "LOGIN_NAME = #{loginName}",
    [[
      and USER_NAME like concat('%',#{userName},'%')
    ]]
  }
}
--]===]
module(..., package.seeall)

local util_str = require("luastar.util.str")

local function getsql_value(sql, data, nv)
    local var, var1, var2 = nil, {}, {}
    -- #{}
    for word in string.gmatch(sql, "#{[%w_]+}") do
        var = string.sub(word, 3, string.len(word) - 1) -- sub #{}
        table.insert(var1, var)
    end
    -- ${}
    for word in string.gmatch(sql, "%${[%w_]+}") do
        var = string.sub(word, 3, string.len(word) - 1) -- sub ${}
        table.insert(var2, var)
    end
    for i, key in ipairs(var1) do
        local value = "null"
        if data[key] then
            if _.isString(data[key]) then
                value = "'" .. string.gsub(data[key], "'", "''") .. "'"
            elseif _.isNumber(data[key]) then
                value = data[key]
            end
        end
        if nv and value == "null" then
            sql = ""
        else
            value = string.gsub(value, "%%", "%%%%")
            sql = string.gsub(sql, "#{" .. key .. "}", value)
        end
    end
    for i, key in ipairs(var2) do
        local value = "null"
        if data[key] then
            value = string.gsub(data[key], "'", "''")
        end
        if nv and value == "null" then
            sql = ""
        else
            value = string.gsub(value, "%%", "%%%%")
            sql = string.gsub(sql, "${" .. key .. "}", value)
        end
    end
    return sql
end

local function getsql_set(set, data)
    if not set then
        return " "
    end
    if not _.isArray(set) then
        return " "
    end
    local s, st = nil, {}
    for i, key in ipairs(set) do
        s = getsql_value(key, data, true)
        if s and s ~= "" then
            table.insert(st, s)
        end
    end
    return " set " .. table.concat(st, ",")
end

local function getsql_where(where, data)
    if not where then
        return " "
    end
    if not _.isArray(where) then
        return " "
    end
    local w, wt = nil, {}
    for i, key in ipairs(where) do
        w = getsql_value(key, data, true)
        if w and w ~= "" then
            table.insert(wt, w)
        end
    end
    if _.size(wt) == 0 then
        return " "
    end
    local rs = util_str.trim(table.concat(wt, " \n"))
    if util_str.startsWith(rs, "and") then
        rs = string.sub(rs, 4, string.len(rs))
    elseif util_str.startsWith(rs, "or") then
        rs = string.sub(rs, 3, string.len(rs))
    end
    return " where " .. rs
end

function getsql(sql_table, data)
    if not sql_table or not _.isTable(sql_table) then
        ngx.log(ngx.ERR, "mysql_util getsql sql_table is nil.")
        return nil
    end
    -- set tag value
    local sql, tag = sql_table["sql"], {}
    for word in string.gmatch(sql, "@{[%w_]+}") do
        var = string.sub(word, 3, string.len(word) - 1) -- sub @{}
        table.insert(tag, var)
    end
    for i, key in ipairs(tag) do
        local value = ""
        if key == "set" then
            value = getsql_set(sql_table["set"], data)
        elseif key == "where" then
            value = getsql_where(sql_table["where"], data)
        end
        value = string.gsub(value, "%%", "%%%%")
        sql = string.gsub(sql, "@{" .. key .. "}", value)
    end
    -- set var value
    return getsql_value(sql, data)
end
