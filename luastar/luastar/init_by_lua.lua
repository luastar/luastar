--[[
在“ngx_lua”模块的“init_by_lua_file”命令中执行;
只在启动nginx时初始化一次。
--]]

-- luastar 全局变量
LUASTAR_G = _G
-- luastar 全局配置table
LUASTAR_C = {}

-- cjson
cjson = require("cjson")
cjson.encode_empty_table_as_object(false)
-- 常用函数
_ = require("moses")
-- class类
Class = require("luastar.core.class")
-- 缓存
luastar_cache = require("luastar.core.cache")
-- 配置
luastar_config = require("luastar.core.config")
-- 上下文
luastar_context = require("luastar.core.context")
-- 日志
logger = require("luastar.util.logger")



