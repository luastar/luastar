--[[
    在 ngx_lua 模块 init_by_lua_file 阶段执行;
--]]

-- 加载常用库
local _ = require("utils.moses")
local cjson = require("cjson")
local logger = require("base.logger")
local ls_cache = require("base.cache")
local ls_config = require("base.config")
local ls_context = require("base.context")

-- cjson 默认配置
cjson.encode_empty_table_as_object(false)

-- 定义全局配置
local LUASTAR_C = {}

-- 定义全局变量
_G._ = _
_G.cjson = cjson
_G.logger = logger
_G.ls_cache = ls_cache
_G.ls_config = ls_config
_G.ls_context = ls_context
_G.LUASTAR_C = LUASTAR_C
