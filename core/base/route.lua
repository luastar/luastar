--[[
应用路由模块，需要在 nginx 配置文件中定义应用路径：APP_PATH。
应用路由配置文件路径：APP_PATH/config/route.lua
--]]

local file_util = require("utils.file_util")
local str_util = require("utils.str_util")

local _M = {}
local mt = { __index = _M }

-- 初始化
function _M:new(config_file)
    if not config_file then
        logger.error("路由初始化失败: 配置文件为空！")
        return
    end
    logger.info("路由初始化: 配置文件[", config_file, "]")
    local config = file_util.load_lua(config_file)
    -- 初始化路由配置
    local instance = {
        config_file = config_file,
        config_routes = config["routes"] or {},
        config_interceptors = config["interceptors"] or {}
    }
    return setmetatable(instance, mt)
end

--[===[
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
--]===]
function _M:match_route(path, method)
    if _.isEmpty(path) or _.isEmpty(method) then
        logger.error("匹配路由失败：请求路径或方法名为空！")
        return nil
    end
    -- 路由匹配
    for i, val in ipairs(self.config_routes) do
        if str_util.path_and_method_is_macth(path, method, val["path"], val["method"], val["mode"]) then
            return val
        end
    end
    logger.debug("匹配路由失败：找不到匹配的路由[", path, "]")
    return nil
end

--[===[
拦截器配置，注：拦截器必须实现beforeHandle和afterHandle方法
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
--]===]
function _M:match_interceptor(path, method)
    if _.isEmpty(path) or _.isEmpty(method) then
        logger.error("匹配拦截器失败：请求路径或方法为空！")
        return nil
    end
    if not _.isArray(self.config_interceptors) then
        logger.error("匹配拦截器失败：拦截器配置不是数组！")
        return nil
    end
    local interceptor_ary = {}
    for idx, interceptor in ipairs(self.config_interceptors) do
        if _.isArray(interceptor["routes"]) then
            -- 是否拦截
            local is_interceptor = false
            -- 请求方式 和 uri 是否匹配
            for idx2, route in ipairs(interceptor["routes"]) do
                if str_util.path_and_method_is_macth(path, method, route["path"], route["method"], route["mode"]) then
                    is_interceptor = true
                    if _.isArray(interceptor["exclude_routes"]) then
                        -- 是否被排除
                        for idx3, exclude_route in ipairs(interceptor["exclude_routes"]) do
                            if str_util.path_and_method_is_macth(path, method, exclude_route["path"], exclude_route["method"], exclude_route["mode"]) then
                                is_interceptor = false
                                break
                            end
                        end
                    end
                    break
                end
            end
            -- 添加到拦截器列表
            if is_interceptor then
                table.insert(interceptor_ary, interceptor["module"])
            end
        end
    end
    return interceptor_ary
end

return _M