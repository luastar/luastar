local _M = {}

-- 级别
local level = {
    SYSTEM = "system",
    USER = "user",
}
_M.level = level

-- 状态
local state = {
    ENABLE = "enable",
    DISABLE = "disable",
}
_M.state = state

-- 配置值类型
local config_vtype = {
    OBJECT = "object",
    ARRAY = "array",
    STRING = "string",
    NUMBER = "number",
    BOOLEAN = "boolean",
}
_M.config_vtype = config_vtype

return _M
