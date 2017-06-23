--[[
全匹配路由，优先级高
route = {
  {"url1","file1","method"},
  {"url2","file2","method"}
}
模式匹配路由
route_pattern = {
  {"url1","file1","method"},
  {"url2","file2","method"}
}
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
--]]
route = {
    { "/api/test/hello", "com.luastar.demo.ctrl.test.hello", "hello" },
    { "/api/test/pic", "com.luastar.demo.ctrl.test.hello", "pic" },
    { "/api/test/mysql", "com.luastar.demo.ctrl.test.mysql", "mysql" },
    { "/api/test/mysql/transaction", "com.luastar.demo.ctrl.test.mysql", "transaction" },
    { "/api/test/redis", "com.luastar.demo.ctrl.test.redis", "redis" },
    { "/api/test/baidu", "com.luastar.demo.ctrl.test.httpclient", "baidu" },
    { "/api/test/proxy", "com.luastar.demo.ctrl.test.httpclient", "proxy" },
    { "/api/test/form", "com.luastar.demo.ctrl.test.form", "form" }
}

interceptor = {
    {
        url = {
            { "*", "/api/.*", true }
        },
        class = "com.luastar.demo.interceptor.common"
    }
}