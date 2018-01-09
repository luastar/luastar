--[[

--]]
local _M = {}

local src_path = "/src/?.lua"
local route_file = "/config/route.lua"
local bean_file = "/config/bean.lua"
local msg_file = "/config/msg.lua"

function _M.init_pkg_path()
	local pkg_path_init = luastar_cache.get("pkg_path_init")
	if pkg_path_init then
		return
	end
	package.path = package.path .. ";" .. ngx.var.APP_PATH .. src_path
	luastar_cache.set("pkg_path_init", true)
end

function _M.getRoute()
	local route = luastar_cache.get("route")
	if route then
		return route
	end
	local Route = require("luastar.core.route")
	route = Route(ngx.var.APP_PATH .. route_file)
	luastar_cache.set("route", route)
	return route
end

function _M.getBeanFactory()
	local bean_factory = luastar_cache.get("bean_factory")
	if bean_factory then
		return bean_factory
	end
	local BeanFactory = require("luastar.core.beanfactory")
	bean_factory = BeanFactory(ngx.var.APP_PATH .. bean_file)
	luastar_cache.set("bean_factory", bean_factory)
	return bean_factory
end

--[[
获取消息配置
msg_live = {
    ["400002"] = "参数%s错误！",
    ["600"] = {
    	["01"] = "haha"
    }
}
--]]
local function getMsgConfig(k)
	local app_msg = luastar_cache.get("app_msg")
	if app_msg then
		return app_msg[k]
	end
	ngx.log(ngx.DEBUG, "init app msg.")
	local util_file = require("luastar.util.file")
	local msg_file = ngx.var.APP_PATH .. msg_file
	app_msg = util_file.loadlua_nested(msg_file) or {}
	ngx.log(ngx.DEBUG, "app_msg=", cjson.encode(app_msg))
	luastar_cache.set("app_msg", app_msg)
	return app_msg[k]
end

--[[
普通消息
local message = luastar_context.getMsg("msg_live", "100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.getMsg("msg_live", "100002"):format(100.00)
多级配置消息获取方法
local message = luastar_context.getMsg("msg_live", "100003", "001")
--]]
function _M.getMsg(k, ...)
	local val = getMsgConfig(k)
	if _.isEmpty(val) then
		return string.format("msg %s not config.", k)
	end
	local tab = { ... }
	local path = k
	for i, v in ipairs(tab) do
		val = val[v]
		path = path .. "[\"" .. v .. "\"]"
		if _.isEmpty(val) then
			return string.format("msg %s not config.", path)
		end
	end
	return val
end

return _M