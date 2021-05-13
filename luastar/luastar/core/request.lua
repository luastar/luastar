--[[
	请求类
--]]
local Request = Class("luastar.core.Request")

local upload = require("resty.upload")

--[[
	构造函数
--]]
function Request:init()
	ngx.log(ngx.DEBUG, "[Request:init] start.")
	self.schema = ngx.var.schema
	self.uri = ngx.var.uri
	self.request_method = ngx.var.request_method
	self.request_uri = ngx.var.request_uri
	self.query_string = ngx.var.query_string
	self.content_type = ngx.var.content_type
	-- 缓存头信息
	self.headers_init = false
	self.headers = nil
	-- 缓存 query 参数
	self.uri_args_init = false
	self.uri_args = nil
	-- 缓存 json 参数
	self.json_args_init = false
	self.json_args = nil
	-- 缓存 post 参数
	self.post_args_init = false
	self.post_args = nil
	-- 缓存 复合 参数
	self.multipart_args_init = false
	self.multipart_args = nil
	-- 缓存 表体
	self.request_body_init = false
	self.request_body = nil
	-- 缓存 表体 json
	self.request_body_json_init = false
	self.request_body_json = nil
end

--[[
	是否复合请求（表单 + 文件）
--]]
function Request:is_multipart()
	if not self.content_type then
		return false
	end
	local m = string.match(self.content_type, "multipart/form%-data")
	if m then
		return true
	else
		return false
	end
end

--[[
	是否 json 请求
--]]
function Request:is_json()
	if not self.content_type then
		return false
	end
	local m = string.match(self.content_type, "application/json")
	if m then
		return true
	else
		return false
	end
end

--[[
	获取参数
--]]
function Request:get_arg(name, default)
	-- 优先从 query 获取
	local arg = self:get_uri_arg(name)
	if arg then
		return arg
	end
	if self:is_multipart() then
		return self:get_multipart_arg(name, default)
	elseif self:is_json() then
		return self:get_json_arg(name, default)
	else
		return self:get_post_arg(name, default)
	end
end

--[[
	获取 query 参数
--]]
function Request:get_uri_arg(name, default)
	if not name then
		return default
	end
	-- 初始化
	if not self.uri_args_init then
		self.uri_args = ngx.req.get_uri_args()
		self.uri_args_init = true
	end
	if not self.uri_args then
		return default
	end
	local arg = self.uri_args[name]
	if not arg then
		return default
	end
	-- 包含多个值，取第一个非空的
	if _.isTable(arg) then
		for i, v in ipairs(arg) do
			if v and string.len(v) > 0 then
				return v
			end
		end
		return default
	else
		return arg
	end
end

--[[
	获取 post 参数
--]]
function Request:get_post_arg(name, default)
	if not name then
		return default
	end
	-- 初始化
	if not self.post_args_init then
		ngx.req.read_body()
		local call_ok, post_args = pcall(ngx.req.get_post_args)
		if call_ok then
			self.post_args = post_args
		end
		self.post_args_init = true
	end
	if not self.post_args then
		return default
	end
	local arg = self.post_args[name]
	if not arg then
		return default
	end
	if _.isTable(arg) then
		for i, v in ipairs(arg) do
			if v and string.len(v) > 0 then
				return v
			end
		end
		return default
	else
		return arg
	end
end

--[[
	获取 复合 参数
--]]
function Request:get_multipart_arg(name, default)
	if not self.multipart_args_init then
		self:init_multipart_args()
		self.multipart_args_init = true
	end
	if not self.multipart_args then
		return default
	end
	local arg = self.multipart_args[name]
	if not arg then
		return default
	else
		if arg.filename then
			-- file
			return arg
		elseif arg.value then
			return arg.value
		else
			return arg
		end
	end
end

function Request:init_multipart_args()
	local form, err = upload:new(8192)
	if not form then
		ngx.log(ngx.ERR, "failed to new upload: ", err)
		return
	end
	form:set_timeout(120000) -- 120s
	local multipart_args = {}
	local upkey, filename = nil, nil
	while true do
		local typ, res, err = form:read()
		if not typ then
			ngx.log(ngx.debug, "failed to read: ", err)
			break
		end
		if typ == "header" then
			if string.upper(res[1]) == "CONTENT-DISPOSITION" then
				local fmatch = string.gmatch(res[2], '"(.-)"')
				if fmatch then
					upkey = fmatch()
					filename = fmatch()
				end
				if upkey then
					multipart_args[upkey] = { filename = filename }
				end
			end
		elseif typ == "body" then
			local file_info = multipart_args[upkey] or {}
			file_info.value = res
			file_info.flen = tonumber(string.len(res))
			multipart_args[upkey] = file_info
		elseif typ == "part_end" then
			ngx.log(ngx.DEBUG, "file[", upkey, "] upload success.")
		elseif typ == "eof" then
			break
		end
	end
	self.multipart_args = multipart_args
end

--[[
	获取 表体
--]]
function Request:get_request_body()
	-- 初始化
	if not self.request_body_init then
		ngx.req.read_body()
		local request_body = ngx.req.get_body_data()
		if request_body then
			self.request_body = request_body
		else
			-- body may get buffered in a temp file
			local body_file = ngx.req.get_body_file()
			if body_file then
				ngx.log(logger.i("body is in file ", tostring(body_file)))
				local body_file_handle, err = io.open(body_file, "r")
				if body_file_handle then
					body_file_handle:seek("set")
					request_body = body_file_handle:read("*a")
					body_file_handle:close()
					self.request_body = request_body
				else
					ngx.log(logger.e("failed to open ", tostring(body_file), "for reading: ", tostring(err)))
					self.request_body = ""
				end
			else
				self.request_body = ""
			end
		end
		self.request_body_init = true
	end
	return self.request_body
end

--[[
	获取 表体 json
--]]
function Request:get_request_body_json()
	-- 初始化
	if not self.request_body_json_init then
		local request_body = self:get_request_body()
		if not _.isEmpty(request_body) then
			local call_ok, request_body_json = pcall(cjson.decode, request_body)
			if call_ok then
				self.request_body_json =  request_body_json
			end
		end
		self.request_body_json_init = true
	end
	return self.request_body_json
end

--[[
	获取 表体 json 参数
--]]
function Request:get_json_arg(name, default)
	if not name then
		return default
	end
	local request_body_json = self:get_request_body_json()
	if not request_body_json then
		return default
	end
	return request_body_json[name] or default
end

--[[
	获取 请求头
--]]
function Request:get_header(name, default)
	if not self.headers_init then
		self.headers = ngx.req.get_headers()
		self.headers_init = true
	end
	if not self.headers then
		return default
	end
	return self.headers[name] or default
end

--[[
 获取多个header，返回一个table
 eg. request: get_header_table("appkey","devid","devmac")
 retrun {appkey="aa", devid="bb", devmac="cc"} 
--]]
function Request:get_header_table(...)
	if not self.headers_init then
		self.headers = ngx.req.get_headers()
		self.headers_init = true
	end
	if not self.headers then
		return {}
	end
	return _.pick(self.headers, ...)
end

--[[
	获取 ip
--]]
function Request:get_ip()
	return self:get_header("X-Forwarded-For") or self:get_header("X-Real-IP", self.remote_addr)
end

--[[
	获取 cookie
--]]
function Request:get_cookie(name, decrypt)
	local value = ngx.var["cookie_" .. name]
	if value and value ~= "" and decrypt == true then
		value = ndk.set_var.set_decode_base64(value)
		value = ndk.set_var.set_decrypt_session(value)
	end
	return value
end

return Request

