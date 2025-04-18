--[[
    在 ngx_lua 模块 init_by_lua_file 阶段执行;
--]]

-- 加载常用库
local _ = require "moses"
local cjson = require "cjson"
local logger = require "core.logger"
local cache = require "core.cache"

-- cjson 默认配置
cjson.encode_empty_table_as_object(false)

-- 定义全局变量
_G.LUASTAR_CACHE = {}
_G._ = _
_G.cjson = cjson
_G.logger = logger
_G.ls_cache = cache
