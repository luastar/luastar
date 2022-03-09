--[[
文件工具类
https://github.com/keplerproject/luafilesystem
--]]
local _M = {}

function _M.loadlua(file)
	ngx.log(ngx.INFO, "加载lua文件：", file)
	local env = setmetatable({}, { __index = _G })
	local fct = assert(loadfile(file))
	setfenv(fct, env)
	assert(pcall(fct))
	setmetatable(env, nil)
	return env
end

function _M.loadlua_nested(file)
	local file_t = _M.loadlua(file)
	local file_include = file_t["_include_"]
	if _.isEmpty(file_include) then
		return file_t
	end
	local file_loaded = { file }
	for i, val in ipairs(file_include) do
		val = ngx.var.APP_PATH .. val -- 增加相对路径
		if not _.contains(file_loaded, val) then
			file_t = _M.loadlua_include(val, file_loaded, file_t)
		else
			ngx.log(ngx.INFO, file, "文件已经加载过，无需重复加载。")
		end
	end
	file_t["_include_"] = nil
	return file_t
end

function _M.loadlua_include(file, file_loaded, super)
	local file_t = _M.loadlua(file)
	table.insert(file_loaded, file)
	local file_include = file_t["_include_"]
	file_t = _.extend(super, file_t)
	if _.isEmpty(file_include) then
		return file_t
	end
	for i, val in ipairs(file_include) do
		val = ngx.var.APP_PATH .. val -- 增加相对路径
		if not _.contains(file_loaded, val) then
			file_t = _M.loadlua_include(val, file_loaded, file_t)
		end
	end
	return file_t
end

return _M