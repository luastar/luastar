#! /usr/bin/env lua
--[[
luastar配置模块，需要在nginx配置文件中定义应用路径：APP_PATH。
应用配置文件路径：APP_PATH/config/app.lua
--]]

module(..., package.seeall)

local util_file = require("luastar.util.file")

function getConfig(k, default_v)
    local app_config = luastar_cache.get("app_config")
    if app_config then
        return app_config[k] or default_v
    end
	local app_config_file = ngx.var.APP_CONFIG or "/config/app.lua"
    local config_file = ngx.var.APP_PATH ..app_config_file
    app_config = util_file.loadlua(config_file) or {}
    luastar_cache.set("app_config", app_config)
    ngx.log(ngx.ERR, "init app config.")
    return app_config[k] or default_v
end