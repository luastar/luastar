--[[
    在 ngx_lua 模块 init_by_lua_file 阶段执行;
--]]

-- luastar 全局变量
LUASTAR_G = _G

-- luastar 全局配置
LUASTAR_C = {}

-- cjson
cjson = require("cjson")
cjson.encode_empty_table_as_object(false)

-- 常用函数
_ = require("moses")

-- 日志
logger = require("core.logger")

-- 缓存
ls_cache = require("core.cache")

-- 配置
ls_config = require("core.config")

-- 上下文
ls_context = require("core.context")


