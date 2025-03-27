--[[
配置模块，需要在nginx配置文件中定义应用路径：APP_PATH。
应用配置文件路径：APP_PATH/config/app.lua
--]]

local file_util = require("utils.file_util")

local _M = {}

function _M.get_config(k, default_v)
	local app_config = ls_cache.get("app_config")
	if app_config then
		return app_config[k] or default_v
	end
	logger.info("init app config.")
	local config_file = ngx.var.APP_PATH .. (ngx.var.APP_CONFIG or "/config/app.lua")
	app_config = file_util.load_lua(config_file) or {}
	ls_cache.set("app_config", app_config)
	return app_config[k] or default_v
end

return _M

