local _M = {}

-- 创建只读表
function _M.create_enum(t)
    local proxy = {}
    local mt = {
        __index = t,
        __newindex = function()
            error("枚举值不允许修改", 2)
        end
    }
    setmetatable(proxy, mt)
    return proxy
end

-- 状态
_M.state = _M.create_enum({
    ENABLE = "enable",
    DISABLE = "disable",
})

-- 模块类型
_M.module_type = _M.create_enum({
    CONTROLLER = "controller",
    INTERCEPTOR = "interceptor",
})

-- 组件类型
_M.widget_type = _M.create_enum({

})

-- 级别
_M.level = _M.create_enum({
    SYSTEM = "system",
    USER = "user",
})

return _M
