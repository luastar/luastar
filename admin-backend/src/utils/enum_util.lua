local _M = {}

-- 级别
_M.LEVEL = {
    SYSTEM = "system",
    USER = "user",
}

-- 状态
_M.STATE = {
    ENABLE = "enable",
    DISABLE = "disable",
}

-- 全部
_M.ALL = "*"

-- 路由匹配模式
_M.ROUTE_MODE = {
    PRECISE = "p",
    VAGUE = "v",
}

-- 配置值类型
_M.CONFIG_VTYPE = {
    OBJECT = "object",
    ARRAY = "array",
    STRING = "string",
    NUMBER = "number",
    BOOLEAN = "boolean",
}

return _M
