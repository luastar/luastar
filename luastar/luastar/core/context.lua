--[[

--]]
local _M = {}

local src_path = "/src/?.lua"
local route_file = "/config/route.lua"
local bean_file = "/config/bean.lua"

function _M.init_pkg_path()
	local pkg_path_init = luastar_cache.get("pkg_path_init")
	if pkg_path_init then
		return
	end
	package.path = package.path .. ";" .. ngx.var.APP_PATH .. src_path
	luastar_cache.set("pkg_path_init", true)
end

function _M.get_route()
	local route = luastar_cache.get("route")
	if route then
		return route
	end
	local Route = require("luastar.core.route")
	route = Route:new(ngx.var.APP_PATH .. route_file)
	luastar_cache.set("route", route)
	return route
end

function _M.get_bean_factory()
	local bean_factory = luastar_cache.get("bean_factory")
	if bean_factory then
		return bean_factory
	end
	local BeanFactory = require("luastar.core.bean_factory")
	bean_factory = BeanFactory:new(ngx.var.APP_PATH .. bean_file)
	luastar_cache.set("bean_factory", bean_factory)
	return bean_factory
end

--[[
普通消息
local message = luastar_context.get_msg("100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.get_msg("100002"):format(100.00)
--]]
function _M.get_msg(key)
	local lang = ngx.ctx.lang or "zh_CN"
	local app_msg = luastar_cache.get("app_msg_" .. lang)
	if app_msg then
		return app_msg[key] or ""
	end
	local util_file = require("luastar.util.file")
	local msg_file = ngx.var.APP_PATH .. "/config/msg_" .. lang .. ".lua"
	app_msg = util_file.loadlua(msg_file)["msg"] or {}
	luastar_cache.set("app_msg_" .. lang, app_msg)
	return app_msg[key] or ""
end

return _M