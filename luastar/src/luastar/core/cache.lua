--[[
luastar缓存模块，使用全局变量“LUASTAR_C”存储；
“LUASTAR_C”在ngx_lua的“init_by_lua_file”指令执行文件“luastar_init.lua”中进行初始化。
为支持多应用，缓存存储在LUASTAR_C[app_name]中，需要在nginx配置文件中定义应用名称：APP_NAME。
--]]

local _M = {}

function _M.get(k, default_v)
	local app_name = ngx.var.APP_NAME or "luastar_app"
	if not LUASTAR_C[app_name] then
		return default_v
	end
	return LUASTAR_C[app_name][k] or default_v
end

function _M.set(k, v)
	local app_name = ngx.var.APP_NAME or "luastar_app"
	if not LUASTAR_C[app_name] then
		LUASTAR_C[app_name] = {}
	end
	LUASTAR_C[app_name][k] = v
end

function setG(k, v)
	LUASTAR_G[k] = v
end

return _M