--[[
luastar应用路由模块，需要在nginx配置文件中定义应用路径：APP_PATH。
应用路由配置文件路径：APP_PATH/config/route.lua
--]]
local util_file = require("luastar.util.file")

local Route = Class("luastar.core.Route")

function Route:init(config_file)
	-- ngx.log(ngx.INFO, "[Route:init] file : ", config_file)
	self.config_file = config_file
	if not self.config_file then
		ngx.log(ngx.ERR, "[Route:init] illegal argument : config_file can't nil.")
		return
	end
	local config = util_file.loadlua(self.config_file)
	-- 初始化路由配置
	self.config_route = config["route"] or {}
	-- ngx.log(ngx.INFO, "[Route:init] config_route : ", cjson.encode(self.config_route))
	-- 初始化拦截器配置
	self.config_interceptor = config["interceptor"] or {}
	-- ngx.log(ngx.INFO, "[Route:init] config_interceptor : ", cjson.encode(self.config_interceptor))
end

function Route:getRoute(uri)
	if _.isEmpty(uri) then
		ngx.log(ngx.ERR, "[Route:getRoute] uri is nil.")
		return nil
	end
	for i, val in ipairs(self.config_route) do
		-- local is,ie = string.find(uri, val)
		if uri == val[1] or uri == (val[1] .. "/") then
			return { class = val[2], method = val[3] }
		end
	end
	ngx.log(ngx.DEBUG, "[Route:getRoute] no url find for uri :", uri)
	return nil
end

function Route:getInterceptor(uri)
	if _.isEmpty(uri) then
		ngx.log(ngx.ERR, "[Route:getRoute] uri is nil.")
		return nil
	end
	local interceptorAry = {}
	_.each(self.config_interceptor, function(i, val)
		local is, ie = string.find(uri, val["url"])
		if not is then
			return
		end
		if val["excludes"] and _.contains(val["excludes"], uri) then
			return
		end
		table.insert(interceptorAry, val["class"])
	end)
	return interceptorAry
end

return Route