--[[
缓存模块，使用全局变量“LUASTAR_C”存储
--]]
local ngx = require "ngx"
local file_util = require "utils.file_util"

local _M = {}

local CACHE_KEY_LUASTAR_PATH = "LUASTAR_PATH"
local CACHE_KEY_LUASTAR_CONFIG_FILE = "LUASTAR_CONFIG_FILE"
local CACHE_KEY_CONFIG = "LUASTAR_CONFIG"
local CACHE_KEY_I18N = "LUASTAR_I18N"
local CACHE_KEY_BEAN_FACTORY = "LUASTAR_BEAN_FACTORY"

--[[
获取缓存
--]]
local function get(k, default_v)
	return LUASTAR_CACHE[k] or default_v
end

--[[
保存缓存
--]]
local function set(k, v)
	LUASTAR_CACHE[k] = v
end

--[[
获取配置
--]]
function _M.get_config(k, default_v)
	local config = get(CACHE_KEY_CONFIG)
	if config then
		return config[k] or default_v
	end
	local config_file = get(CACHE_KEY_LUASTAR_CONFIG_FILE)
	logger.info("init luastar config : ", config_file)
	config = file_util.load_lua(config_file) or {}
	set(CACHE_KEY_CONFIG, config)
	return config[k] or default_v
end

--[[
获取国际化文本
local text = ls_cache.get_text("100001")
占位直接使用string的格式化方法，例如%s, %d等
local text = ls_cache.get_text("100002"):format(100.00)
--]]
function _M.get_text(key)
	local lang = ngx.ctx.lang or "zh_CN"
	local cache_key = CACHE_KEY_I18N .. lang
	local i18n = get(cache_key)
	if i18n then
		return i18n[key] or ""
	end
	local i18n_file = get(CACHE_KEY_LUASTAR_PATH) .. "/admin-backend/config/i18n_" .. lang .. ".lua"
	logger.info("init luastar i18n : ", i18n_file)
	i18n = file_util.load_lua(i18n_file)["msg"] or {}
	set(cache_key, i18n)
	return i18n[key] or ""
end

-- 获取 bean 工厂
function _M.get_bean_factory()
	local bean_factory = get(CACHE_KEY_BEAN_FACTORY)
	if bean_factory then
		return bean_factory
	end
	local bean_file = get(CACHE_KEY_LUASTAR_PATH) .. "/admin-backend/config/bean.lua"
	logger.info("init luastar bean : ", bean_file)
	bean_factory = require("core.bean_factory"):new(bean_file)
	set(CACHE_KEY_BEAN_FACTORY, bean_factory)
	return bean_factory
end

return _M
