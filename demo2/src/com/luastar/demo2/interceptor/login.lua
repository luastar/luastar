--[[
异常处理拦截器
--]]
local _M = {}

local json_util = require("com.luastar.demo2.util.json")

function _M.beforeHandle()
	-- 开发环境禁用缓存
	template.caching(false)
	template.cache = {}
	-- session校验
	if session.check() then
		local data = session.getData("user")
		ngx.log(logger.i("用户session验证通过", cjson.encode(data)))
		return true
	end
	ngx.log(logger.i("用户session验证不通过"))
	local xRequestedWith = ngx.ctx.request:get_header("x-requested-with")
	if _.isEmpty(xRequestedWith) then
		template.render("login.html", { message = "登录超时！" })
	else
		ngx.ctx.response:set_header("session-status", "timeout");
		ngx.ctx.response:writeln(json_util.timeout())
	end
	return false
end

function _M.afterHandle(ctrl_call_ok, err_info)
	if not ctrl_call_ok then
		ngx.ctx.response:writeln(json_util.exp(err_info))
	end
end

return _M