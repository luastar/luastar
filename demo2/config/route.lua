--[[
-- 频次限制
limit = { class = "xxx.yyy.zzz", method = "limit" }

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
	{ "*", "/", "com.luastar.demo2.ctrl.index", "index" },
	{ "*", "/system/login", "com.luastar.demo2.ctrl.login", "login" },
	{ "*", "/system/logout", "com.luastar.demo2.ctrl.login", "logout" },
	{ "*", "/system/user", "com.luastar.demo2.ctrl.system.user", "index" },
	{ "*", "/system/user/list", "com.luastar.demo2.ctrl.system.user", "list" },
	{ "*", "/system/user/edit", "com.luastar.demo2.ctrl.system.user", "edit" },
	{ "*", "/system/user/save", "com.luastar.demo2.ctrl.system.user", "save" }
}

interceptor = {
	{
		url = {
			{ "*", "/.*", true }
		},
		class = "com.luastar.demo2.interceptor.login",
		excludes = { "/system/login" }
	}
}