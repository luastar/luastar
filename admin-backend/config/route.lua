--[[
-- 路由配置
routes = {
    {
        path = "/api/hello", -- 请求路径，模式匹配使用 Lua 的模式匹配规则
        method = "GET,POST", -- 请求方法，多个方法用逗号分隔，*表示所有方法
        mode = "p",  -- 匹配模式 p(precise:精确匹配) | v(vague:模糊匹配)
        module = "ctrl.hello",  -- 模块路径，相对于后端项目根目录
        func = "hello", -- 模块函数名
        params = { a="1", b="2" } -- 路由参数，可选
    }
}

-- 拦截器配置
-- 注：拦截器必须实现 beforeHandle 和 afterHandle 方法
interceptors = {
    {
        routes = {
            {
                path = "/api/*", -- 请求路径，模式匹配使用 Lua 的模式匹配规则
                method = "GET,POST", -- 请求方法，多个方法用逗号分隔，*表示所有方法
                mode = "v"  -- 匹配模式 p(precise:精确匹配) | v(vague:模糊匹配)
            }
        },
        module = "file",
        exclude_routes = {
            {
                path = "/api/hello",
                method = "GET,POST",
                mode = "p"
            }
        }
    }
}
--]]

routes = {
    {
        path = "/api/hello",
        method = "GET,POST",
        mode = "p",
        module = "ctrl.hello",
        func = "hello",
        params = { a = "1", b = "2" }
    }
}

interceptors = {
    {
        routes = { 
            {
                path = "^/api/.*",
                method = "*",
                mode = "v"
            } 
        },
        module = "plugins.interceptor_auth",
        exclude_routes = {
            -- {
            --     path = "/api/hello",
            --     method = "*",
            --     mode = "p"
            -- }
        }
    }
}
