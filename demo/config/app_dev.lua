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
