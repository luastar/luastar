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
    logger.info("Route init file : ", config_file)
    if not config_file then
        logger.error("[Route init] illegal argument : config_file can't nil.")
        return
    end
    local config = file_util.load_lua(config_file)
    -- 初始化路由配置
    local instance = {
        config_file = config_file,
        config_route = config["route"] or {},
        config_route_pattern = config["route_pattern"] or {},
        config_interceptor = config["interceptor"] or {}
    }
    return setmetatable(instance, mt)
end

--[===[
-- 全匹配路由，优先级高
-- 第1列：请求方式，第2列：路由，第3列：文件，第4列：方法，第5列：扩展参数
route = {
  { "*", "url1", "file1", "method", { p1="v1", p2="v2" } },
  { "GET,POST", url2", "file2", "method" }
}

-- 模式匹配路由
-- 第1列：请求方式，第2列：路由，第3列：文件，第4列：方法，第5列：扩展参数
route_pattern = {
  { "*", "url1", "file1", "method", { p1="v1", p2="v2" } },
  { "GET", "url2", "file2", "method" }
}
--]===]
function _M:get_route(method, uri)
    if _.isEmpty(method) or _.isEmpty(uri) then
        logger.error("[Route getRoute] method or uri is nil.")
        return nil
    end
    -- 全匹配
    for i, val in ipairs(self.config_route) do
        if str_util.method_and_uri_is_macth(method, uri, val[1], val[2], false) then
            return { class = val[3], method = val[4], param = val[5] }
        end
    end
    -- 模式匹配
    for i, val in ipairs(self.config_route_pattern) do
        if str_util.method_and_uri_is_macth(method, uri, val[1], val[2], true) then
            return { class = val[3], method = val[4], param = val[5] }
        end
    end
    logger.debug("[Route getRoute] no url find for uri :", uri)
    return nil
end

--[===[
拦截器配置，注：拦截器必须实现beforeHandle和afterHandle方法
interceptor = {
    {
        url = {
            { "*", "url1", true },  -- method, url, pattern
            { "POST", "url2", false },
        },
        class = "file",
        excludes = {
            "url1",
            "url2"
        }
    }
}
--]===]
function _M:get_interceptor(method, uri)
    if _.isEmpty(method) or _.isEmpty(uri) then
        logger.error("[Route getInterceptor] uri is nil.")
        return nil
    end
    if not _.isArray(self.config_interceptor) then
        logger.error("[Route getInterceptor] config is not a array.")
        return nil
    end
    local interceptor_ary = {}
    for idx, interceptor in ipairs(self.config_interceptor) do
        if _.isArray(interceptor["url"]) then
            -- 是否拦截
            local is_interceptor = false
            -- 请求方式 和 uri 是否匹配
            for idx2, url in ipairs(interceptor["url"]) do
                if str_util.method_and_uri_is_macth(method, uri, url[1], url[2], url[3]) then
                    is_interceptor = true
                    if _.isArray(interceptor["excludes"]) then
                        -- 是否被排除
                        for idx3, exclude_url in ipairs(interceptor["excludes"]) do
                            if str_util.method_and_uri_is_macth(method, uri, "*", exclude_url, false) then
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
                table.insert(interceptor_ary, interceptor["class"])
            end
        end
    end
    return interceptor_ary
end

return _M