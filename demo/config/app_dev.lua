--[[
应用配置文件
--]]

limit_config = {
    dict_limit_req = "dict_limit_req",
    -- 默认限制
    default = {
        limit_count = {
            { url = { "/api/test/hello", false }, time = 3600, count = 5 }
        },
        limit_req = {
            { url = { "/.*", true }, rate = 100, burst = 100 }
        }
    },
    -- 特定用户限制
    uid_xxx = {
        limit_ip = { "127.0.0.1", "192.168.0.1" },
        limit_count = {
            { url = { "/api/test/hello", false }, time = 120, count = 3 }
        },
        limit_req = {
            { url = { "/.*", true }, rate = 2, burst = 1 }
        }
    }
}

mysql = {
    host = "127.0.0.1",
    port = "3306",
    user = "root",
    password = "root123",
    database = "luastar-cms",
    timeout = 30000,
    pool_size = 1000
}

redis = {
    host = "127.0.0.1",
    port = "6379",
    auth = "",
    timeout = 30000,
    pool_size = 1000
}

_include_ = {
    "/config/app_dev_a.lua",
    "/config/app_dev_b.lua"
}
