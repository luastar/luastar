--[===[
#{}，如果值为字符串，则添加前后添加单引号'，如果为空，处理为null
${}，直接替换，如果为空，处理为null
@{}，引用其他语句
sql_table = {
  sql = [[
    update SYS_USER @{set} @{where} @{limit}
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
  limit = {
    start = "${start}",
    limit = "${limit}"
  }
}
--]===]

local str_util = require("utils.str_util")

local _M = {}

--[[
替换语句中的变量
sql 带有#{}或${}变量的语句
data 变量值对象
nv 变量值为空的时候是否处理为null
--]]
local function get_sql_value(sql, data, nv)
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
		if data[key] ~= nil and data[key] ~= "" then
			if _.isString(data[key]) then
				-- 防sql注入
				-- value = "'" .. string.gsub(data[key], "'", "''") .. "'"
				value = ngx.quote_sql_str(data[key])
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
		if data[key] ~= nil and data[key] ~= "" then
			-- 防sql注入
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

local function get_sql_set(set, data)
	if not set then
		return " "
	end
	if not _.isArray(set) then
		return " "
	end
	local s, st = nil, {}
	for i, key in ipairs(set) do
		s = get_sql_value(key, data, true)
		if s and s ~= "" then
			table.insert(st, s)
		end
	end
	return " set " .. table.concat(st, ",")
end

local function get_sql_where(where, data)
	if not where then
		return " "
	end
	if not _.isArray(where) then
		return " "
	end
	local w, wt = nil, {}
	for i, key in ipairs(where) do
		w = get_sql_value(key, data, true)
		if w and w ~= "" then
			table.insert(wt, w)
		end
	end
	if _.size(wt) == 0 then
		return " "
	end
	local rs = str_util.trim(table.concat(wt, " \n"))
	if str_util.start_with(rs, "and") then
		rs = string.sub(rs, 4, string.len(rs))
	elseif str_util.start_with(rs, "or") then
		rs = string.sub(rs, 3, string.len(rs))
	end
	return " where " .. rs
end

local function get_sql_limit(limit, data)
	if not limit then
		return " "
	end
	local start = tonumber(get_sql_value(limit["start"], data, false))
	local limit = tonumber(get_sql_value(limit["limit"], data, false))
	if start == nil or limit == nil then
		return " "
	end
	return string.format(" limit %d, %d", start, limit)
end

function _M.getsql(sql_table, data)
	if not sql_table or not _.isTable(sql_table) then
		logger.error("mysql_util getsql sql_table is nil.")
		return nil
	end
	if not data or not _.isTable(data) then
		logger.error("mysql_util getsql data is nil, sql is ", sql_table["sql"])
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
			value = get_sql_set(sql_table["set"], data)
		elseif key == "where" then
			value = get_sql_where(sql_table["where"], data)
		elseif key == "limit" then
			value = get_sql_limit(sql_table["limit"], data)
		end
		value = string.gsub(value, "%%", "%%%%")
		sql = string.gsub(sql, "@{" .. key .. "}", value)
	end
	-- set var value
	return get_sql_value(sql, data, false)
end

return _M
