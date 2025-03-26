--[[
缓存模块，使用全局变量“LUASTAR_C”存储
--]]

local _M = {}

local APP_NAME_DEFAULT = "LuastarApp"

function _M.get(k, default_v)
	local app_name = ngx.var.APP_NAME or APP_NAME_DEFAULT
	if not LUASTAR_C[app_name] then
		return default_v
	end
	return LUASTAR_C[app_name][k] or default_v
end

function _M.set(k, v)
	local app_name = ngx.var.APP_NAME or APP_NAME_DEFAULT
	if not LUASTAR_C[app_name] then
		LUASTAR_C[app_name] = {}
	end
	LUASTAR_C[app_name][k] = v
end

return _M