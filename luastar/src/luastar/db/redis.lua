#!   /usr/bin/env lua
--[[
redis操作库
--]]
local resty_redis = require("resty.redis")

Redis = Class("luastar.db.Redis")

function Redis:init(datasource)
    self.datasource = _.defaults(datasource, {
        host = "127.0.0.1",
        port = "6379",
        auth = nil,
        timeout = 3000,
        max_idle_timeout = 60000,
        pool_size = 1000
    })
    ngx.log(ngx.DEBUG, "[Redis:init] datasource : ", cjson.encode(self.datasource))
end

function Redis:getConnect()
    local connect, err = resty_redis:new()
    if not connect then
        ngx.log(ngx.ERR, "[Redis:getConnect] failed to create redis : ", err)
        return nil
    end
    connect:set_timeout(self.datasource.timeout)
    local ok, err = connect:connect(self.datasource.host, self.datasource.port)
    if not ok then
        ngx.log(ngx.ERR, "[Redis:getConnect] failed to connect redis : ", err)
        return nil
    end
    if self.datasource.auth then
        local res, err = connect:auth(self.datasource.auth)
    end
    return connect
end

function Redis:cmd(method, ...)
    local connect = self:getConnect()
    if not connect then
        return nil
    end
    ngx.log(ngx.DEBUG, "[Redis:cmd] connected to redis ok.")
    -- exec cmd
    local res, err = connect[method](connect, ...)
    -- close
    self:close(connect)
    return res, err
end

function Redis:close(connect)
    if not connect then
        return
    end
    if self.datasource.pool_size <= 0 then
        connect:close()
        return
    end
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle timeout
    local ok, err = connect:set_keepalive(self.datasource.max_idle_timeout, self.datasource.pool_size)
    if not ok then
        ngx.log(ngx.ERR, "[Redis:close] set keepalive failed : ", err)
    else
        ngx.log(ngx.DEBUG, "[Redis:close] set keepalive ok.")
    end
end

return Redis