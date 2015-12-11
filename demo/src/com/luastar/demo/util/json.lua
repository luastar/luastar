#!/usr/bin/env lua
--[[
	接口输出通用json格式
]]
module(..., package.seeall)

local date_util = require("luastar.util.date")

function success(data, needFormat)
	local body = data or {}
	local rs = {
		head = {
			status = 1,
			msg = "ok.",
			datakey = date_util.get_timestamp(),
			timestamp=  ngx.time()
		},
		body = body
	}
	if needFormat then
		return string.gsub(cjson.encode(rs),"{}","[]")
	end
	return cjson.encode(rs)
end

function illegal_argument(msg)
	local rs = {
		head = {
			status = 2,
			msg = msg or "参数错误。",
			datakey = date_util.get_timestamp(),
			timestamp= ngx.time()
		}
	}
	return cjson.encode(rs)
end

function exp(msg)
	local rs = {
		head = {
			status = 3,
			msg = msg or "系统异常。",
			datakey = date_util.get_timestamp(),
			timestamp=  ngx.time()
		}
	}
	return cjson.encode(rs)
end

function fail(msg)
	local rs = {
		head = {
			status = 4,
			msg = msg or "处理失败。",
			datakey = date_util.get_timestamp(),
			timestamp= ngx.time()
		}
	}
	return cjson.encode(rs)
end

function illegal_token(msg)
	local rs = {
		head = {
			status = 5,
			msg = msg or "登录超时。",
			datakey = date_util.get_timestamp(),
			timestamp= ngx.time()
		}
	}
	return cjson.encode(rs)
end

function jsonp(callback, json)
	if _.isEmpty(callback) then
		return json
	end
	return table.concat({ callback, "(", json, ")" }, "")
end




