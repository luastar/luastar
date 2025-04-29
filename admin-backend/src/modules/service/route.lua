--[===[
    路由管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取用户信息
--]]
function _M.get_user_info(username)

end

--[[
 获取用户角色和权限
--]]
function _M.get_user_role_permission(uid)

end

return _M
