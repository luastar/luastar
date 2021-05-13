--[[
在“ngx_lua”模块的“init_by_lua_file”命令中执行;
只在启动nginx时初始化一次。
--]]

-- luastar 全局变量
LUASTAR_G = _G
-- luastar 全局配置table
LUASTAR_C = {}

-- class
Class = require("luastar.core.class")
-- cjson
cjson = require("cjson")
cjson.encode_empty_table_as_object(false)

-- underscore
_ = require("moses")

-- luastar 缓存模块
luastar_cache = require("luastar.core.cache")
-- luastar 配置模块
luastar_config = require("luastar.core.config")
-- luastar 上下文模块
luastar_context = require("luastar.core.context")
-- luastar session
session = require("luastar.core.session")
-- luastar 日志模块
logger = require("luastar.util.logger")



