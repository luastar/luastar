--[[
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

-- 拦截器配置，注：拦截器必须实现beforeHandle和afterHandle方法
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
--]]

route = {
    { "GET,POST", "/api/hello", "api.hello", "hello", { a="1", b="2"} },
}

interceptor = {
    {
        url = {
            { "*", "/api/.*", true }
        },
        class = "plugins.interceptor_auth"
    }
}