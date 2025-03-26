--[[
	上下文
--]]
local Route = require("core.route")
local BeanFactory = require("core.bean_factory")

local _M = {}

-- 初始化项目包路径
function _M.init_pkg_path()
	local pkg_path_init = ls_cache.get("pkg_path_init")
	if pkg_path_init then
		return
	end
	package.path = package.path .. ";" .. ngx.var.APP_PATH .. "/src/?.lua"
	ls_cache.set("pkg_path_init", true)
end

-- 获取路由配置
function _M.get_route()
	local route = ls_cache.get("route")
	if route then
		return route
	end
	route = Route:new(ngx.var.APP_PATH .. "/config/route.lua")
	ls_cache.set("route", route)
	return route
end

-- 获取 bean 工厂
function _M.get_bean_factory()
	local bean_factory = ls_cache.get("bean_factory")
	if bean_factory then
		return bean_factory
	end
	bean_factory = BeanFactory:new(ngx.var.APP_PATH .. "/config/bean.lua")
	ls_cache.set("bean_factory", bean_factory)
	return bean_factory
end

--[[
消息
local message = ls_context.get_msg("100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = ls_context.get_msg("100002"):format(100.00)
--]]
function _M.get_msg(key)
	local lang = ngx.ctx.lang or "zh_CN"
	local app_msg = ls_cache.get("app_msg_" .. lang)
	if app_msg then
		return app_msg[key] or ""
	end
	local file_util = require("utils.file_util")
	local msg_file = ngx.var.APP_PATH .. "/config/msg_" .. lang .. ".lua"
	app_msg = file_util.load_lua(msg_file)["msg"] or {}
	ls_cache.set("app_msg_" .. lang, app_msg)
	return app_msg[key] or ""
end

return _M
