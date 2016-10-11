--[[
luastar消息模块，默认路径：APP_PATH/config/msg.lua
--]]

module(..., package.seeall)

local util_file = require("luastar.util.file")

function getMsgConfig(k, default_v)
    local app_msg = luastar_cache.get("app_msg")
    if app_msg then
        return app_msg[k] or default_v
    end
    --ngx.log(ngx.INFO, "init app msg.")
    local msg_file = ngx.var.APP_PATH .. "/config/msg.lua"
    app_msg = util_file.loadlua_nested(msg_file) or {}
    --ngx.log(ngx.INFO, "app_msg=", cjson.encode(app_msg))
    luastar_cache.set("app_msg", app_msg)
    return app_msg[k] or default_v
end

function getMsg(k, ...)
    -- ngx.log(ngx.INFO, "获取文本信息：", k, ...)
    local val = getMsgConfig(k)
    if _.isEmpty(val) then
        return string.format("msg %s not config.", k)
    end
    local tab = { ... }
    local path = k
    for i, v in ipairs(tab) do
        val = val[v]
        path = path .. "[\"" .. v .. "\"]"
        if _.isEmpty(val) then
            return string.format("msg %s not config.", path)
        end
    end
    return val
end

