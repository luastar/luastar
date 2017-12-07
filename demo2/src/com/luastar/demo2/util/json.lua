--[[
	接口输出通用json格式
--]]
local _M = {}

function _M.toJson(data, needFormat)
	local rs = data or {}
	if needFormat then
		return string.gsub(cjson.encode(rs), "{}", "[]")
	end
	return cjson.encode(rs)
end

function _M.success(rsMsg)
	return _M.toJson({
		code = "0",
		msg = rsMsg or "success!"
	})
end

function _M.fail(rsMsg)
	return _M.toJson({
		code = "1",
		msg = rsMsg or "fail!"
	})
end

function _M.timeout(rsMsg)
	return _M.toJson({
		code = "99",
		msg = rsMsg or "timeout!"
	})
end

function _M.jsonp(callback, json)
	if _.isEmpty(callback) then
		return json
	end
	return table.concat({ callback, "(", json, ")" }, "")
end

return _M




