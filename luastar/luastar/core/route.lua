--[[
luastar应用路由模块，需要在nginx配置文件中定义应用路径：APP_PATH。
应用路由配置文件路径：APP_PATH/config/route.lua
--]]
local Route = luastar_class("luastar.core.Route")

local util_file = require("luastar.util.file")
local util_str = require("luastar.util.str")

function Route:init(config_file)
    -- ngx.log(ngx.INFO, "[Route:init] file : ", config_file)
    self.config_file = config_file
    if not self.config_file then
        ngx.log(ngx.ERR, "[Route:init] illegal argument : config_file can't nil.")
        return
    end
    local config = util_file.loadlua(self.config_file)
    -- 初始化限制
    self.config_limit = config["limit"] or {}
    -- 初始化路由配置
    self.config_route = config["route"] or {}
    self.config_route_pattern = config["route_pattern"] or {}
    -- ngx.log(ngx.INFO, "[Route:init] config_route : ", cjson.encode(self.config_route))
    -- 初始化拦截器配置
    self.config_interceptor = config["interceptor"] or {}
    -- ngx.log(ngx.INFO, "[Route:init] config_interceptor : ", cjson.encode(self.config_interceptor))
end

--[===[
访问限制策略
limit = { file = "", method = "" }
--]===]
function Route:get_limit()
    return self.config_limit
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
function Route:get_route(method, uri)
    if _.isEmpty(method) or _.isEmpty(uri) then
        ngx.log(ngx.ERR, "[Route:getRoute] method or uri is nil.")
        return nil
    end
    -- 全匹配
    for i, val in ipairs(self.config_route) do
        if util_str.method_and_uri_is_macth(method, uri, val[1], val[2], false) then
            return { class = val[3], method = val[4], param = val[5] }
        end
    end
    -- 模式匹配
    for i, val in ipairs(self.config_route_pattern) do
        if util_str.method_and_uri_is_macth(method, uri, val[1], val[2], true) then
            return { class = val[3], method = val[4], param = val[5] }
        end
    end
    ngx.log(ngx.DEBUG, "[Route:getRoute] no url find for uri :", uri)
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
function Route:get_interceptor(method, uri)
    if _.isEmpty(method) or _.isEmpty(uri) then
        ngx.log(ngx.ERR, "[Route:getRoute] uri is nil.")
        return nil
    end
    if not _.isArray(self.config_interceptor) then
        ngx.log(ngx.ERR, "[Route:getInterceptor] config is not a array.")
        return nil
    end
    local interceptor_ary = {}
    for idx, interceptor in ipairs(self.config_interceptor) do
        if _.isArray(interceptor["url"]) then
            -- 是否拦截
            local is_interceptor = false
            -- 请求方式 和 uri 是否匹配
            for idx2, url in ipairs(interceptor["url"]) do
                if util_str.method_and_uri_is_macth(method, uri, url[1], url[2], url[3]) then
                    is_interceptor = true
                    if _.isArray(interceptor["excludes"]) then
                        -- 是否被排除
                        for idx3, exclude_url in ipairs(interceptor["excludes"]) do
                            if util_str.method_and_uri_is_macth(method, uri, "*", exclude_url, false) then
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

return Route