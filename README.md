#luastar
##1. 简介
luastar是一个基于[openresty](http://openresty.org/cn/index.html)的高性能高并发开发框架，主要用于移动端app的http接口开发，实现了request/response、缓存、配置文件、路由/拦截器、bean管理、mysql和redis以及httpclient等常用工具类的封装，便于快速开发。
luastar目前只在macOS和centos系统上测试过。
##2. 安装
###2.1 openresty 安装
请参考官网介绍，建议安装目录：/usr/local/openresty
###2.2 luastar 安装
下载项目到到硬盘上，如：/data/apps/luastar下。
修改配置文件(luastar/conf/luastar*.conf)中的相关路径为openresty安装路径和项目存放路径，如下：

```lua
# set search paths for pure Lua external libraries (';;' is the default path):
lua_package_path '/data/apps/luastar/luastar/libs/?.lua;/data/apps/luastar/luastar/src/?.lua;;';
lua_package_cpath '/data/apps/luastar/luastar/libs/?.so;;';

#init luastar
init_by_lua_file '/data/apps/luastar/luastar/src/luastar_init.lua';

server {
  listen 8001;
  server_name localhost;
  set $LUASTAR_PATH '/data/apps/luastar/luastar';
  set $APP_NAME 'demo';
  set $APP_PATH '/data/apps/luastar/demo';
  access_log /data/logs/demo/access.log  main;
  error_log  /data/logs/demo/error.log   info;
  location / {
    default_type text/html;
    content_by_lua_file '${LUASTAR_PATH}/src/luastar_content.lua';
  }
}
```
这里有多个不同环境的配置文件（luastar_dev.conf/luastar_test.conf/laustar.conf），可以在nginx配置文件中引入所需要的一个。
例如：
开发环境（luastar_dev.conf）是在macOS系统上的，增加了特有的"?.dylib"库，同时增加了调试工具[ZeroBrane Studio](http://studio.zerobrane.com/)路径，并且关闭了代码缓存，可在修改代码后不必每次重启nginx。
###2.3 nginx 配置
修改 openresty/nginx/conf/nginx.conf，引入luastar项目配置文件：
include "/data/apps/luastar/luastar/conf/luastar_test.conf";
###2.4 hello world
启动openresty：
openresty/nginx/sbin/nginx -c openresty/nginx/conf/nginx.conf

访问 http://localhost:8001/api/test/hello，
试试带参数访问 http://localhost:8001/api/test/hello?name=haha

##3. 开始
###3.1 项目结构
* luastar
* |----luastar
* |--------conf（nginx配置文件）
* |--------libs（第三方库）
* |--------src（luastar源码）
* |----demo1（项目1）
* |--------config（项目配置）
* |------------app.lua（项目配置文件）
* |------------bean.lua（bean配置文件）
* |------------msg.lua（文案配置文件）
* |------------route.lua（路由/拦截器配置文件）
* |--------src（项目源码）
* |------------com
* |----------------luastar
* |--------------------demo
* |------------------------ctrl（控制类-业务逻辑）
* |------------------------interceptor（拦截器）
* |------------------------service（服务类-公共服务）
* |------------------------util（常用类）
* |----demo2（项目2）
* |--------config（项目配置）
* |--------src（项目源码）

###3.2 全局变量
luastar在初始化时，定义了几个常用的工具，在项目中可以直接使用，不用require引入。
参看：luastar/src/luastar_init.lua

| 变量名 | 用途 |
|-------------|-------------|
| Class | 类定义 |
| cjson | json处理类 |
| _ | Moses常用工具类 |
| luastar_cache | 缓存 |
| luastar_config | 配置 |
| luastar_context | 上下文 |
| logger | 日志辅助 |

第三方工具类：
* [csjon](http://www.kyne.com.au/~mark/software/lua-cjson.php)
* [moses](https://github.com/Yonaba/Moses)
* [http](https://github.com/liseen/lua-resty-http)
* ...

###3.3 缓存
在项目中，如果有需要缓存的数据，可使用luastar_cache来存放和读取

```lua
luastar_cache.get("app_config")
luastar_cache.set("app_config", app_config)
```
注：luastar的缓存根据openresty的机制，每个nginx的worker会存放一份，如果需要在worker中共用，请使用openresty提供的字典（支持的数据结构有限）

###3.4 上下文
```lua
--获取路由
local route = luastar_context.getRoute()
--获取bean
local beanFactory = luastar_context.getBeanFactory()
local redis_util = beanFactory:getBean("redis")
```
###3.5 日志
luastar日志直接使用openresty中提供的ngx.log实现，之前有使用第三方log包写文件，但效果不太理想，容易丢失日志。
luastar提供了一个辅助类，主要用于日志跟踪。

```lua
ngx.log(logger.info(p1,p2,p3,...))
-- 也可以使用简写
ngx.log(logger.i(p1,p2,p3,...))
```
设计在每次请求中生成一个request_id，在使用上述方式输出的日志中都会带有该标识，例如：--[MJw7NMaz5cGn6u3TV9hM]--。

```log
2016/10/11 17:01:11 [info] 90429#0: *8 [lua] hello.lua:9: --[MJw7NMaz5cGn6u3TV9hM]--name=world, try to give a param with name., client: 127.0.0.1, server: localhost, request: "GET /api/test/hello HTTP/1.1", host: "localhost:8001"
```
###3.6 配置文件
项目配置可根据不同环境配置多个，
例如在测试环境的luastar/conf/luastar_test.conf中设置：
set $APP_CONFIG '/config/app_test.lua';

```lua
server {
  listen 8001;
  server_name localhost;
  set $LUASTAR_PATH '/data/apps/luastar/luastar';
  set $APP_NAME 'demo';
  set $APP_PATH '/data/apps/luastar/demo';
  set $APP_CONFIG '/config/app_test.lua';
  access_log /data/logs/demo/access.log  main;
  error_log  /data/logs/demo/error.log   info;
  location / {
    default_type text/html;
    content_by_lua_file '${LUASTAR_PATH}/src/luastar_content.lua';
  }
}
```
配置文件直接使用lua语法，例如：

```lua
--[[
应用配置文件
--]]
mysql = {
    host = "localhost",
    port = "3306",
    user = "admin",
    password = "xxx",
    database = "xxx",
    timeout = 30000,
    pool_size = 1000
}
redis = {
    host = "localhost",
    port = "6379",
    auth = "xxx",
    timeout = 30000,
    pool_size = 1000
}
weixin = {
  access_token_url = "https://api.weixin.qq.com/sns/oauth2/access_token",
  check_token_url = "https://api.weixin.qq.com/sns/auth",
  refresh_token_url = "https://api.weixin.qq.com/sns/oauth2/refresh_token",
  userinfo_url = "https://api.weixin.qq.com/sns/userinfo"
}
_include_ = {
    "/config/app_dev_a.lua",
    "/config/app_dev_b.lua"
}
```
_include_ 是一个特殊的用法，支持配置文件嵌套引入。
在代码中可通过luastar_config.getConfig来获取：

```lua
local access_token_url = luastar_config.getConfig("weixin")["access_token_url"]
```
也可以在bean.conf中通过${weixin.access_token_url}获取

```lua
mysql = {
    class = "luastar.db.mysql",
    arg = {
        { value = "${mysql}" }
    }
}
```
配置文件在nginx启动时读取，并存放在缓存中。
###3.7 路由和拦截器
路由和拦截器在demo/config/route.lua文件中配置，例如：

```lua
route = {
    { "/api/test/hello", "com.luastar.demo.ctrl.test.hello", "hello" },
    { "/api/test/mysql", "com.luastar.demo.ctrl.test.mysql", "mysql" },
    { "/api/test/mysql/transaction", "com.luastar.demo.ctrl.test.mysql", "transaction" },
    { "/api/test/redis", "com.luastar.demo.ctrl.test.redis", "redis" },
    { "/api/test/baidu", "com.luastar.demo.ctrl.test.httpclient", "baidu" },
    { "/api/test/form", "com.luastar.demo.ctrl.test.form", "form" }
}

interceptor = {
    {
        url = "/api",
        class = "com.luastar.demo.interceptor.common"
    }
}
```
路由是一个二维数组，每一行表示一个接口地址，第一列表示请求地址（目前只支持全匹配），第二列表示对应的处理类，第三列表示处理类中的方法。
例如：当请求http://localhost:8001/api/test/hello时，由com.luastar.demo.ctrl.test.hello类的hello方法处理。
拦截器与路由稍有不同，每一行指定了属性，url代表拦截的请求，支持lua的模式匹配，class代表拦截器实现，excludes表示排除不处理的请求。

```lua
interceptor = {
  {url="url1", class="file"},
  {url="url2", class="file", excludes={"url1","url2"}}
}
```
拦截器必须实现beforeHandle和afterHandle方法
beforeHandle方法返回一个布尔类型的值，返回true继续执行后续处理，返回false中止退出。
###3.8 bean配置
简化版的spring bean管理，

```lua
id = {	--bean id
  class = "", --类地址
  arg = { --构造参数注入
    {value/ref = ""} --value直接赋值，ref引用其他bean
  },
  property = { --set方法注入，必须实现set_${name}方法
    {name = "",value/ref = ""}
  },
  init_method = "",--初始化方法，默认使用init()
  single = 0  -- 是否单例，默认是
}
```
例如：

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
paramService = {
    class = "com.lajin.service.common.paramService"
}
testService = {
    class = "com.lajin.service.test.testService",
    arg = { { ref = "redis" } }
}
_include_ = {
    "/config/bean_uc.lua"
}
```
bean配置文件也支持_include_引入其他配置的语法
注：在类中定义的方法最好使用类的模式，可以使用luastar框架中的class类定义：

```lua
local testService = Class("com.luastar.demo.service.test.testService")
local table_util = require("luastar.util.table")

function testService:init(redis_util)
    self.redis_util = redis_util
end

--[[
-- 根据uid获取用户信息
--]]
function testService:getUserInfo(uid)
    if _.isEmpty(uid) then
        return nil
    end
    local redis = self.redis_util:getConnect()
    local userinfo = table_util.array_to_hash(redis:hgetall("user:info:" .. uid))
    self.redis_util:close(redis)
    if _.isEmpty(userinfo) then
        ngx.log(logger.e("userinfo is empty, uid=", uid))
        return nil
    end
    ngx.log(logger.i(cjson.encode(userinfo)))
    return userinfo
end

return testService
```

在代码中调用：

```lua
local beanFactory = luastar_context.getBeanFactory()
local mysql_util = beanFactory:getBean("mysql")
```
###3.9 ctrl类
默认给ctrl类的请求处理方法传入了request和response对象，也可通过ngx.ctx.request和ngx.ctx.response获取

```lua
function hello(request, response)
    local name = request:get_arg("name") or "world, try to give a param with name."
    response:writeln("hello, " .. name)
end
```
可以通过request:get_arg("name", "default")获取参数，支持get、post参数，支持文件上传。

##9 联系方式
###QQ群：545501138
###Email：19102630@163.com

