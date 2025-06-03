--[[
  init_by_lua_file 阶段执行
--]]

-- 加载常用库
local _ = require "moses"
local cjson = require "cjson"
local logger = require "core.logger"
local cache = require "core.cache"

do
  -- cjson 默认配置
  cjson.encode_empty_table_as_object(false)
  -- 定义全局变量
  local LUASTAR_PATH = os.getenv("LUASTAR_PATH") or ""
  local LUASTAR_CONFIG_FILE = os.getenv("LUASTAR_CONFIG_FILE") or ""
  _G.LUASTAR_CACHE = {
    LUASTAR_PATH = LUASTAR_PATH,
    LUASTAR_CONFIG_FILE = LUASTAR_PATH .. LUASTAR_CONFIG_FILE,
  }
  _G._ = _
  _G.cjson = cjson
  _G.logger = logger
  _G.ls_cache = cache
end
