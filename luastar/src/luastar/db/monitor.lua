--[[
    数据库连接监控
--]]

local _M = {}

function _M.add(type)
	local debug_table = debug.getinfo(3, "Sl")
	local call_src = debug_table.short_src
	if string.len(call_src) > 20 then
		call_src = string.sub(call_src, -20, -1)
	end
	local debug_info = "+..." .. call_src .. ":" .. debug_table.currentline
	if ngx.ctx[type] == nil then
		ngx.ctx[type] = { count = 1, info = { debug_info } }
	else
		ngx.ctx[type]["count"] = ngx.ctx[type]["count"] + 1
		table.insert(ngx.ctx[type]["info"], debug_info)
	end
end

function _M.sub(type)
	local debug_table = debug.getinfo(3, "Sl")
	local call_src = debug_table.short_src
	if string.len(call_src) > 20 then
		call_src = string.sub(call_src, -20, -1)
	end
	local debug_info = "-..." .. call_src .. ":" .. debug_table.currentline
	if ngx.ctx[type] == nil then
		ngx.ctx[type] = { count = 0, info = { debug_info } }
	else
		ngx.ctx[type]["count"] = ngx.ctx[type]["count"] - 1
		table.insert(ngx.ctx[type]["info"], debug_info)
	end
end

function _M.check(...)
	local typeAry = { ... }
	for i, type in ipairs(typeAry) do
		if ngx.ctx[type] ~= nil and ngx.ctx[type]["count"] > 0 then
			ngx.log(ngx.ERR, "check ", type, " not closed ", ngx.var.uri)
			ngx.log(ngx.ERR, "check info ", table.concat(ngx.ctx[type]["info"], ","))
		end
	end
end

return _M

