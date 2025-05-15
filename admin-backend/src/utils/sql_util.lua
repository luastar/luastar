--[===[
#{}，防SQL注入替换
${}，直接替换
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
  },
  limit = {
    limit = "${limit}",
		offset = "${offset}"
  }
}
--]===]
local ngx = require "ngx"
local str_util = require "utils.str_util"

local _M = {}

--[[
替换语句中的变量
sql 带有#{}或${}变量的语句
data 变量值对象
nv 变量值为空的时候是否处理为""，用于动态 set 和 where 条件
--]]
local function fmt_sql_value(sql, data, nv)
	local var, var1, var2 = nil, {}, {}
	-- 查找 #{}
	for word in string.gmatch(sql, "#{[%w_]+}") do
		var = string.sub(word, 3, string.len(word) - 1) -- sub #{}
		table.insert(var1, var)
	end
	-- 查找 ${}
	for word in string.gmatch(sql, "%${[%w_]+}") do
		var = string.sub(word, 3, string.len(word) - 1) -- sub ${}
		table.insert(var2, var)
	end
	for i, key in ipairs(var1) do
		local value = str_util.null
		if not _.isNil(data[key]) then
			if _.isString(data[key]) then
				value = ngx.quote_sql_str(data[key]) -- 防sql注入
			elseif _.isNumber(data[key]) then
				value = data[key]
			end
		end
		if nv and value == str_util.null then
			sql = ""
		else
			value = string.gsub(value, "%%", "%%%%") -- 特殊符号转义
			sql = string.gsub(sql, "#{" .. key .. "}", value)
		end
	end
	for i, key in ipairs(var2) do
		local value = str_util.null
		if not _.isNil(data[key]) then
			value = data[key]
		end
		if nv and value == str_util.null then
			sql = ""
		else
			value = string.gsub(value, "%%", "%%%%")
			sql = string.gsub(sql, "${" .. key .. "}", value)
		end
	end
	return sql
end

local function fmt_sql_set(set, data)
	if not set then
		return " "
	end
	if not _.isArray(set) then
		return " "
	end
	local s, st = nil, {}
	for i, key in ipairs(set) do
		s = fmt_sql_value(key, data, true)
		if not _.isEmpty(s) then
			table.insert(st, s)
		end
	end
	return " set " .. table.concat(st, ", ")
end

local function fmt_sql_where(where, data)
	if not where then
		return " "
	end
	if not _.isArray(where) then
		return " "
	end
	local w, wt = nil, {}
	for i, key in ipairs(where) do
		w = fmt_sql_value(key, data, true)
		if not _.isEmpty(w) then
			table.insert(wt, w)
		end
	end
	if _.size(wt) == 0 then
		return " "
	end
	local rs = str_util.trim(table.concat(wt, " "))
	if str_util.start_with(rs, "and") then
		rs = string.sub(rs, 4, string.len(rs))
	elseif str_util.start_with(rs, "or") then
		rs = string.sub(rs, 3, string.len(rs))
	end
	return " where " .. rs
end

local function fmt_sql_limit(limit_obj, data)
	if not limit_obj then
		return " "
	end
	local limit = fmt_sql_value(limit_obj["limit"], data, false)
	local offset = fmt_sql_value(limit_obj["offset"], data, false)
	if _.isEmpty(limit) or _.isEmpty(offset) then
		return " "
	end
	return string.format(" limit %d offset %d", tonumber(limit), tonumber(offset))
end

function _M.fmt_sql_table(sql_table, data)
	if not sql_table or not _.isTable(sql_table) then
		logger.error("mysql_util fmt_sql_table sql_table is nil.")
		return nil
	end
	if not data or not _.isTable(data) then
		logger.error("mysql_util fmt_sql_table data is nil, sql is ", sql_table["sql"])
		return nil
	end
	-- 查找 @{}
	local sql, tag = sql_table["sql"], {}
	for word in string.gmatch(sql, "@{[%w_]+}") do
		local var = string.sub(word, 3, string.len(word) - 1) -- sub @{}
		table.insert(tag, var)
	end
	for i, key in ipairs(tag) do
		local value = ""
		if key == "set" then
			value = fmt_sql_set(sql_table["set"], data)
		elseif key == "where" then
			value = fmt_sql_where(sql_table["where"], data)
		elseif key == "limit" then
			value = fmt_sql_limit(sql_table["limit"], data)
		end
		value = string.gsub(value, "%%", "%%%%")
		sql = string.gsub(sql, "@{" .. key .. "}", value)
	end
	-- set var value
	return fmt_sql_value(sql, data, false)
end

function _M.fmt_sql(sql, data)
	if not sql or not _.isString(sql) then
		logger.error("mysql_util fmt_sql sql is nil.")
		return nil
	end
	if not data or not _.isTable(data) then
		logger.error("mysql_util fmt_sql data is nil, sql is ", sql)
		return nil
	end
	-- set var value
	return fmt_sql_value(sql, data, false)
end

return _M
