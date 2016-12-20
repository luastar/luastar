--[[
异常处理拦截器
--]]
local _M = {}

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
	template.render("login.html", { message = "login timeout!" })
	return false
end

function _M.afterHandle(ctrl_call_ok, err_info)
	if not ctrl_call_ok then
		ngx.ctx.response:writeln(json_util.exp(err_info))
	end
end

return _M