# luastar
# 1. luastar简介
## 1.1 luastar是一个基于openresty的高性能高并发高效率http接口和web网站开发框架

## 1.2 luastar主要特性：
* request/response封装
* 缓存管理
* 配置文件管理
* 路由/访问频次/拦截器配置
* 类似 spring bean 服务管理
* mysql和redis访问封装
* httpclient等常用工具封装

# 2.  luastar安装
## 2.1 openresty 安装
请参考官网介绍，https://openresty.org/cn/installation.html

建议安装目录：/data/apps/openresty

## 2.2 luastar 安装
### 2.2.1 下载luastar
从github下载luastar到本地目录，例如：/data/apps/luastar下。

### 2.2.2 修改luastar配置
替换配置文件『/yourpath/luastar/demo/config-ng/luastar*.conf』中的openresty安装路径和luastar存放路径，如下：

``` conf
## 该配置文件最好放到openresty/nginx/conf/**/下统一进行管理
## 设置lua包路径(';;'是默认路径，?.dylib是macos上的库，?.so是centos上的库)
lua_package_path '/Users/zhuminghua/Documents/code-zmh/luastar/luastar/?.lua;;';
lua_package_cpath '/Users/zhuminghua/Documents/code-zmh/luastar/luastar/?.dylib;/Users/zhuminghua/Documents/code-zmh/luastar/luastar/?.so;;';

## luastar初始化
init_by_lua_file '/Users/zhuminghua/Documents/code-zmh/luastar/luastar/luastar/init_by_lua.lua';

## 设置成一样避免获取request_body时可能会缓存到临时文件
#client_max_body_size 64m;
#client_body_buffer_size 64m;

## 请求频次限制字典
lua_shared_dict dict_limit_req 64m;
lua_shared_dict dict_limit_count 64m;

server {
  listen 8001;
  ## 关闭后不用重启nginx即可访问最新代码，生产环境一定要置为on（默认值）
  #lua_code_cache off;
  server_name localhost;
  ## luastar路径
  set $LUASTAR_PATH '/Users/zhuminghua/Documents/code-zmh/luastar/luastar';
  ## 应用名称
  set $APP_NAME 'demo';
  ## 应用路径
  set $APP_PATH '/Users/zhuminghua/Documents/code-zmh/luastar/demo';
  ## 应用使用的配置，可区分开发/生产环境，默认使用app.lua
  set $APP_CONFIG '/config/app_dev.lua';
  ## 访问日志
  access_log  '/Users/zhuminghua/Documents/logs/luastar_demo/access.log' main;
  ## 错误/输出日志
  error_log   '/Users/zhuminghua/Documents/logs/luastar_demo/error.log'  info;
  location / {
    default_type text/html;
    content_by_lua_file '${LUASTAR_PATH}/luastar/content_by_lua.lua';
  }
}
```
luastar/conf/目录下多个文件分别对应不同环境，例如luastar_dev.conf是开发环境的配置，luastar.conf是生产环境的配置

### 2.2.3 修改nginx配置
修改openresty/nginx/conf/nginx.conf，引入luastar项目配置文件：

```conf
include /Users/zhuminghua/Documents/code-zmh/luastar/demo/config-ng/luastar_dev.conf;
```

### 2.2.4 启动nignx
```shell
/usr/local/openresty/nginx/sbin/nginx -c openresty/nginx/conf/nginx.conf
```

## 2.3 测试访问
http://localhost:8001/api/test/hello
http://localhost:8001/api/test/hello?name=haha

# 3 api开发
## 3.1 luastar 项目结构
```
luastar	// luastar项目
	luastar		// luastar源码
	**		// 第三方库，可自行添加
demo	// demo项目
	config	// 配置目录
		app*.lua		// 配置文件
		bean.lua		// bean配置
		msg.lua		// 文案配置
		route.lua		// 路由/频次控制/拦截器配置
	config-ng	// nginx配置文件
		luastar.lua		// 生产环境
		luastar_dev.lua		// 开发环境
	src		// 源码目录
		com
			luastar
				demo	// 包
					ctrl			// 控制类目录
					interceptor	// 拦截器
					service		// 服务类
					util			// 辅助类
```

## 3.2 luastar 全局变量
luastar 在初始化时，定义了几个常用的全局变量，在项目中可以直接使用，不用require引入，详情请参看：luastar/src/luastar_init.lua

|全局变量 | 说明 |
| :--- | :--- |
| cjson | json工具类 |
| _ | moses工具类（部分修改） |
| Class | luastar中的类定义 |
| luastar_cache | luastar缓存 |
| luastar_config | luastar配置 |
| luastar_context | luastar上下文 |
| logger | luastar日志 |

## 3.3 缓存
luastar提供了lua内存缓存，根据openresty机制，每个worker存有一份，所以在使用缓存前，需要先判断是否存在（即使初始化存储过），luastar中使用缓存存储了配置文件信息、bean信息、路由和拦截器信息等等。
例如：luastar/src/core/config.lua

```lua
local _M = {}

local util_file = require("luastar.util.file")

function _M.get_config(k, default_v)
	-- 从缓存中获取配置信息
	local app_config = luastar_cache.get("app_config")
	if app_config then
		-- 如果配置信息存在，返回
		return app_config[k] or default_v
	end
	-- 如果配置信息不存在，初始化
	ngx.log(ngx.INFO, "init app config.")
	-- 加载配置文件
	local app_config_file = ngx.var.APP_CONFIG or "/config/app.lua"
	local config_file = ngx.var.APP_PATH .. app_config_file
	app_config = util_file.loadlua_nested(config_file) or {}
	-- 缓存配置信息
	luastar_cache.set("app_config", app_config)
	-- 返回结果
	return app_config[k] or default_v
end

return _M
```

说明：内存缓存的好处在于支持所有的lua结构，没有限制。

如果需要缓存的内容比较简单或者可以序列化成json，可以考虑使用[ngx.shared.DICT](https://github.com/iresty/nginx-lua-module-zh-wiki#ngxshareddict)，实现全局共享。

## 3.4 luastar_context 上下文
有些内容在init_by_lua阶段无法初始化，需要延后在content_by_lua阶段执行，不能放到初始化阶段里作为全局变量直接使用，所以放到了上下文中，详见：luastar/src/luastar/core/context.lua

### 3.4.1 初始化项目包路径和获取路由
初始化项目包路径和获取路由已经在请问入口类中调用了，实际项目中应该不会调用，详见：luastar/src/luastar/luastar_content.lua

### 3.4.2 获取bean_factory
bean_factory是参考spring中的bean管理实现的一套lua bean，用于服务层，和require进来的对象相比，最大的区别是lua bean是用类实例化出来的对象，可以是单例的，也可以是多实例的，有自己的属性和方法。

``` lua
-- 获取mysql服务
local bean_factory = luastar_context.get_bean_factory()
local mysql_util = bean_factory:get_bean("mysql")
-- 创建链接
local mysql = mysql_util:get_connect()
-- 执行sql
local res, err, errno, sqlstate = mysql:query("select * from user")
ngx.log(logger.i(cjson.encode({
	sql = sql,
	res = res,
	err = err,
	errno = errno,
	sqlstate = sqlstate
})))
-- 关闭链接
mysql_util:close(mysql)
```

### 3.4.3 获取msg
项目中可能需要将输出的文案配置到配置文件中，便于做国际化或替换。
例如：demo/conf/msg.lua

```lua
--[[
提示消息配置
普通消息
local message = luastar_context.get_msg("msg_live", "100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.get_msg("msg_live", "100002"):format(100.00)
多级配置消息获取方法
local message = luastar_context.get_msg("msg_live", "100003", "001")
--]]
msg_pub = {
    ["100001"] = "错误1！", --
    ["100002"] = "金额不能超过%d元！", --
    ["100003"] = {
        ["001"] = "错误3-1！", --
        ["002"] = "错误3-2"
    }, --
    ["199999"] = nil
}
msg_uc = {
    ["200001"] = "错误1！", --
    ["200002"] = "错误2！", --
    ["200003"] = "错误3！", --
    ["299999"] = nil
}
```

## 3.5 调试与日志
## 3.5.1 调试
luastar/openresty可以利用[ZeroBraneStudio](https://studio.zerobrane.com/)工具调试。

openresty使用ZeroBraneStudio调试步骤可参考链接：[http://notebook.kulchenko.com/zerobrane/debugging-openresty-nginx-lua-scripts-with-zerobrane-studio](http://notebook.kulchenko.com/zerobrane/debugging-openresty-nginx-lua-scripts-with-zerobrane-studio)

luastar使用ZeroBranStudio调试步骤如下：

1、在包路径中增加ZeroBranStudio相关库文件，注意macos使用.dylib，centos上使用.so库

```conf
lua_package_path 'luastar其他库;/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?/?.lua;/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/lualibs/?.lua;;';
lua_package_cpath 'luastar其他库;/Applications/ZeroBraneStudio.app/Contents/ZeroBraneStudio/bin/clibs/?.dylib;;';
```

2、在需要调试的代码前后加上

```lua
require('mobdebug').start("127.0.0.1")
-- 调试代码
require('mobdebug').done()
```

3、断点，按ZeroBranStudio方法启动调试
## 3.5.2 日志
如果觉得调试起来麻烦，日志就是最好的调试办法，简单高效（熟练后完全可以不需要调试）。

luastar直接使用ngx.log输出，之前也有用过第三方库 [https://github.com/Neopallium/lualogging](https://github.com/Neopallium/lualogging) 在多worker模式中容易造成日志丢失。ngx.log的缺点是不能个性化按天输出（可以用脚本定时分割），输出大小有限制，不过一般也够用了。

luastar只是简单封装了固定输出trace_id和简化的方法，不包装起来是为了直观的输出日志的位置

```
ngx.log(logger.info("name=", name))
-- 或者
ngx.log(logger.i("name=", name))
```

输出结果：

```
2016/12/19 17:01:50 [info] 14545#0: *553 [lua] hello.lua:12: --[2y6hNDFGd4Nxi7FE9UAP]--name=world, try to give a param with name., client: 127.0.0.1, server: localhost, request: "GET /api/test/hello HTTP/1.1", host: "localhost:8001"
```
[2y6hNDFGd4Nxi7FE9UAP]是本次请求的trace_id，便于在日志量大的情况下定位一次请求的所有日志。

## 3.6 项目配置
一般项目都会有配置文件，在luastar项目中，配置文件放在demo/config/目录下，可以通过在luastar.conf文件中指定不同环境的配置，默认使用app.lua文件

```conf
server {
	listen 8001;
	...
	set $APP_CONFIG '/config/app_dev.lua';
	...
}
```

配置文件的内容直接使用lua语法

```lua
--[[
应用配置文件
--]]
mysql = {
	host = "10.1.1.2",
	port = "3306",
	user = "root",
	password = "lajin2015",
	database = "cms_admin",
	timeout = 30000,
	pool_size = 1000
}
redis = {
	host = "10.1.1.4",
	port = "6382",
	auth = "lajin@2015",
	timeout = 30000,
	pool_size = 1000
}

_include_ = {
	"/config/app_dev_a.lua",
	"/config/app_dev_b.lua"
}
```

_include_ 是一个特殊的用法，支持配置文件嵌套引入。

配置文件的内容在代码中，可以通过luastar_config.get_config来获取：

```lua
local mysqlDataSource = luastar_config.get_config("mysql")
local mysqlDataSourceHost = luastar_config.get_config("mysql")["host"]
```

配置文件的内容也可以直接在bean.lua中使用，

```lua
mysql = {
	class = "luastar.db.mysql",
	arg = {
		{ value = "${mysql}" }
	}
}
```

详情请参考bean的配置用法。

## 3.7 频次控制/路由/拦截器
路由/拦截器在demo/config/route.lua文件中配置

```lua
-- 全匹配路由，优先级高
route = {
	{ "*", "/api/test/hello", "com.luastar.demo.ctrl.test.hello", "hello", { p1="v1", p2="v2" } },
	{ "POST", "/api/test/pic", "com.luastar.demo.ctrl.test.hello", "pic" },
	{ "*", "/api/test/mysql", "com.luastar.demo.ctrl.test.mysql", "mysql" },
	{ "*", "/api/test/mysql/transaction", "com.luastar.demo.ctrl.test.mysql", "transaction" },
	{ "GET,POST", "/api/test/redis", "com.luastar.demo.ctrl.test.redis", "redis" }
}

-- 模式匹配路由
route_pattern = {
	{ "*", "/aaa/.*", "com.luastar.demo.ctrl.test.dispatcher", "aaa", { p1="v1", p2="v2" } }, -- aaa
	{ "*", "/bbb/.*", "com.luastar.demo.ctrl.test.dispatcher", "bbb" }, -- bbb
	{ "*", "/ccc/.*", "com.luastar.demo.ctrl.test.dispatcher", "ccc" }, -- ccc
	{ "*", "/.*", "com.luastar.demo.ctrl.test.dispatcher", "other" } -- 默认
}

-- 拦截器配置，注：拦截器必须实现beforeHandle和afterHandle方法
interceptor = {
	{
		url = {
			{ "*", "/api/.*", true }
		},
		class = "com.luastar.demo.interceptor.common"
	}
}
```

### 3.7.1 路由
路由分为全匹配路由和模式匹配路由，全匹配优先级高，不支持路径取值（不建议），模式使用lua自带的模式。

路由是一个二维数组，每一行表示一个接口地址，第一列表示请求方式（*表示不限制，多个请求方式用逗号分隔，v1.4版本新增），第二列表示请求地址，第三列表示对应的处理类，第四列表示处理类中的方法，第五列表示自定义参数（以第三个参数传到处理类方法中）

luastar默认给ctrl类请求处理方法传入了request/response对象（其他地方可通过ngx.ctx.request和ngx.ctx.response获取）和路由中第五列的自定义参数，用于处理输入和输出和路由扩展。

参考：
demo/src/com/luastar/demo/ctrl/test/hello.lua

### 3.7.2 拦截器
拦截器每一行表示一个拦截器（优先级取决于数组顺序），url为数组，支持同时拦截多个url，每个url是一个数组（第一列表示拦截的请求方法，*代表所有，第二列可以是模式的，取决于第三列），class代表拦截器实现，excludes表示该拦截器不处理的请求数组。

注：1.2 版本前后结构不同

拦截器要实现两个方法beforeHandle和afterHandle，beforeHandle必须返回布尔类型的结果，只要有一个拦截器返回false，则ctrl不会执行，beforeHandle可以返回第二个参数（字符串类型），用于返回false后的输出结果（返回true时忽略）

参考：demo/src/com/luastar/demo/interceptor/common.lua

## 3.8 lua bean 管理
luastar实现了简化版的spring bean factory，默认将bean实例化后以单例模式（每个worker一份）存在缓存中，和require进来的对象相比，最大的区别是lua bean是用类实例化出来的对象，可以是单例的，也可以是多实例的，有自己的属性和方法。

### 3.8.1 定义bean
bean在配置文件demo/config/bean.lua文件中配置，注意保证id的唯一性

```lua
--[[
id = { -- bean id
	class = "", -- 类地址
	arg = { -- 构造参数注入
		{value/ref = ""} -- value赋值，ref引用其他bean
	},
	property = { -- set方法注入，实现set_${name}方法
		{name = "",value/ref = ""}
	},
	init_method = "", -- 初始化方法，默认使用init()
	single = 0 -- 是否单例，默认是1
}
--]]
-- mysql服务
mysql = {
	class = "luastar.db.mysql",
	arg = {
		{ value = "${mysql}" }
	}
}
-- redis服务
redis = {
	class = "luastar.db.redis",
	arg = {
		{ value = "${redis}" }
	}
}
-- 系统用户服务
userService = {
	class = "com.luastar.demo2.service.system.userService"
}
-- 功能服务
funcService = {
	class = "com.luastar.demo2.service.system.funcService"
}
-- 角色服务
roleService = {
	class = "com.luastar.demo2.service.system.roleService"
}
-- 角色关系服务
userRoleRelationService = {
	class = "com.luastar.demo2.service.system.userRoleRelationService"
}
-- 引入其他模块
_include_ = {
	"/config/bean_uc.lua"
}
```
bean配置文件也支持_include_引入其他配置的语法。
在类中定义的方法最好使用类的模式，存储私有变量，可以使用luastar框架中的class类定义。
参考：
demo2/src/com/luastar/demo2/service/system/userService.lua

### 3.8.2 使用bean
在代码中先获取bean工厂，再获取bean

```lua
function _M.list(request, response)
	local param = {
		draw = request:get_arg("draw"),
		start = tonumber(request:get_arg("start")) or 0,
		limit = tonumber(request:get_arg("length")) or 10,
		keyword = request:get_arg("query_username")
	}
	-- 查询结果
	local bean_factory = luastar_context.get_bean_factory()
	local userService = bean_factory:get_bean("userService")
	local num = userService:countUser(param);
	local data = {}
	if num > 0 then
		data = userService:getUserList(param);
	end
	-- 返回结果
	local result = {
		draw = param["draw"],
		recordsTotal = num,
		recordsFiltered = num,
		data = data
	}
	response:writeln(json_util.toJson(result, true))
end
```
## 3.9 mysql / redis 封装及使用
luastar中对mysql和redis的操作基于openresty官方提供的组件：
[LuaRestyMySQLLibrary](https://openresty.org/cn/lua-resty-mysql-library.html) 
[LuaRestyRedisLibrary](https://openresty.org/cn/lua-resty-redis-library.html)

luastar中对mysql和redis提供了以下功能：
1. 数据源配置
2. 获取连接
3. 关闭连接（使用连接池）
4. mysql事务
5. sql语句动态拼装

### 3.9.1 配置数据源
demo2/conf/app.lua中配置相关数据源，例如：

```lua
mysql = {
	  host = "127.0.0.1",
	  port = "3306",
	  user = "root",
	  password = "xxx",
	  database = "xxx",
	  timeout = 30000,
	  pool_size = 1000
}
redis = {
	  host = "127.0.0.1",
	  port = "6379",
	  auth = "xxx",
	  timeout = 30000,
	  pool_size = 1000
}
```

### 配置bean
demo2/conf/bean.lua中配置mysql/redis bean，多数据源可以配置多个，id不一样即可。

```lua
mysql = {
	class = "luastar.db.mysql",
	arg = {
		{ value = "${mysql}" }
	}
}
redis = {
	class = "luastar.db.redis",
	arg = {
		{ value = "${redis}" }
	}
}
```

### 3.9.3 使用

```lua
-- 获取封装类
local bean_factory = luastar_context.get_bean_factory()
local mysql_util = bean_factory:get_bean("mysql")
local redis_util = bean_factory:get_bean("redis")

-- 对于单次请求操作，可直接使用下列语句，不用获取和关闭连接
mysql_util.query("sql")
redis_util.hgetall("key")

-- 对于多次请求操作，需要先获取到连接，依次执行，最后关闭连接
local mysql = mysql_util:get_connect()
local res1, err1, errno1, sqlstate1 = mysql:query(sql1)
local res2, err2, errno2, sqlstate2 = mysql:query(sql2)
mysql_util:close(mysql)

local redis = redis_util:get_connect()
local userinfo = table_util.array_to_hash(redis:hgetall("user:info:" .. uid))
redis_util:close(redis)
```

### 3.9.4 动态sql语句
```lua
local _M = {}

local sql_util = require("luastar.util.sql")

function _M.mysql(request, response)
	local name = request:get_arg("name") or ""
	local sql_table = {
		sql = [[
			select * from SYS_USER
			@{where}
			order by ID desc
			limit #{start},#{limit}
		]],
		where = {
			"LOGIN_NAME = #{loginName}",
			[[
				and USER_NAME like concat('%',#{userName},'%')
			]]
		}
	}
	local data = { userName = name, start = 0, limit = 10 }
	local sql = sql_util.getsql(sql_table, data)
	local bean_factory = luastar_context.get_bean_factory()
	local mysql_util = bean_factory:get_bean("mysql")
	local mysql = mysql_util:get_connect()
	local res, err, errno, sqlstate = mysql:query(sql)
	mysql_util:close(mysql)
	response:writeln(cjson.encode({
		sql = sql,
		res = res,
		err = err,
		errno = errno,
		sqlstate = sqlstate
	}))
end

function _M.transaction(request, response)
	local bean_factory = luastar_context.get_bean_factory()
	local mysql_util = bean_factory:get_bean("mysql")
	local sqlArray = {
		"update SYS_USER set USER_NAME='管理员1' where ID=1",
		"update SYS_USER set USER_NAME_A='管理员2' where ID=1" -- USER_NAME_A not exists
	}
	local result_table = mysql_util:query_transaction(sqlArray)
	response:writeln(cjson.encode(result_table))
end

return _M
```

完整配置如下：

```lua
-- #{}，如果值为字符串，则增加单引号防sql注入，如果为空，处理为null
-- ${}，直接替换，如果为空，处理为null
-- @{}，引用其他语句
sql_table = {
	sql = [[
		update SYS_USER @{set} @{where} @{limit}
	]],
	set = {
		"USER_NAME = #{userName}", 	-- userName为nil时忽略
		"UPDATED_TIME = #{updatedTime}"
	},
	where = {
		"LOGIN_NAME = #{loginName}", 	-- loginName为nil时该语句忽略
		[[
			and USER_NAME like concat('%',#{userName},'%') -- userName为nil时该语句忽略
		]]
    },
	limit = {
		start = "${start}", -- start和limit为nil时忽略
		limit = "${limit}"
	}
}
```

## 4 联系方式
luastar 完全开源，不限制，欢迎使用和交流。

QQ交流群：545501138

Email：19102630@163.com
