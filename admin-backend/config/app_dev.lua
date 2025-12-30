--[[
应用配置文件
--]]

-- Mysql 数据库配置
local mysql_config = {
  host = "127.0.0.1",
  port = "3306",
  user = "root",
  password = "root123",
  database = "luastar-admin",
  timeout = 3000,
  pool_size = 100
}

-- Redis 配置
local redis_config = {
  host = "127.0.0.1",
  port = "6379",
  auth = "",
  timeout = 3000,
  pool_size = 100
}

-- JWT 配置
local jwt_config = {
  secret = "LuastarAdminTokenSecret",
  access_expire = 3600 * 2,
  refresh_expire = 3600 * 24 * 30,
}

return {
  mysql_config = mysql_config,
  redis_config = redis_config,
  jwt_config = jwt_config
}
