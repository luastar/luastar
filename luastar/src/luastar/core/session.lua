--[[
web session管理
https://github.com/bungle/lua-resty-session
--]]
local _M = {}

-- 保存session数据，例如在登录后保存用户信息
function _M.save(name, value, opts)
	local session = require("resty.session").start(opts)
	session.data[name] = value
	session:save()
end

-- 获取session数据
function _M.getData(name)
	local session = require("resty.session").open()
	return session.data[name]
end

-- 校验session，同时更新过期时间
function _M.check()
	local session, valid = require("resty.session").open()
	if valid then
		session.start()
		return true
	end
	return false
end

function _M.destroy()
	local session = require("resty.session").start()
	session:destroy()
end

return _M