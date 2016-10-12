#!   /usr/bin/env lua
--[[

--]]
local upload = require("resty.upload")

local Request = Class("luastar.core.Request")

function Request:init()
    ngx.log(ngx.DEBUG, "[Request:init] start.")
    self.host = ngx.var.host
    self.hostname = ngx.var.hostname
    self.uri = ngx.var.uri
    self.schema = ngx.var.schema
    self.request_uri = ngx.var.request_uri
    self.request_method = ngx.var.request_method
    self.request_filename = ngx.var.request_filename
    self.remote_addr = ngx.var.remote_addr
    self.remote_port = ngx.var.remote_port
    self.remote_user = ngx.var.remote_user
    self.remote_passwd = ngx.var.remote_passwd
    self.content_type = ngx.var.content_type
    self.content_length = ngx.var.content_length
    self.http_user_agent = ngx.var.http_user_agent
    self.query_string = ngx.var.query_string
    self.headers = ngx.req.get_headers()
    self.uri_args = ngx.req.get_uri_args()
    self.socket = ngx.req.socket
end

function Request:isMultipart()
    local content_type = self.headers["content-type"]
    if not content_type then
        return false
    end
    local s = string.match(content_type, "multipart/form%-data")
    if s then
        return true
    else
        return false
    end
end

function Request:get_arg(name, default)
    local method = string.upper(self.request_method)
    if method == "GET" then
        return self:get_uri_arg(name, default)
    elseif method == "POST" then
        if self:isMultipart() then
            -- file upload
            return self:get_upload_arg(name) or self:get_uri_arg(name, default)
        end
        return self:get_post_arg(name) or self:get_uri_arg(name, default)
    end
    return default
end

function Request:get_uri_arg(name, default)
    if not name then return default end
    if not self.uri_args then return default end
    local arg = self.uri_args[name]
    if not arg then return default end
    if _.isTable(arg) then
        for i, v in ipairs(arg) do
            if v and string.len(v) > 0 then
                return v
            end
        end
        return default
    end
    return arg
end

function Request:set_uri_args(args)
    return ngx.req.set_uri_args(args)
end

function Request:get_post_arg(name, default)
    if not name then return default end
    if not self.post_args then
        ngx.req.read_body()
        self.post_args = pcall(ngx.req.get_post_args) or {}
    end
    local arg = self.post_args[name]
    if not arg then return default end
    if _.isTable(arg) then
        for i, v in ipairs(arg) do
            if v and string.len(v) > 0 then
                return v
            end
        end
        return default
    end
    return arg
end

function Request:get_upload_arg(name, default)
    self:get_upload_data()
    local arg_data = self.upload_data[name]
    if arg_data then
        if arg_data.filename then
            return arg_data -- file
        else
            return arg_data.value -- not file
        end
    end
    return default
end

function Request:get_upload_data()
    if self.upload_data then return self.upload_data end
    local form, err = upload:new(104857600) -- chunk_size 100m
    if not form then
        ngx.log(ngx.ERR, "failed to new upload: ", err)
        self.upload_data = {}
        return
    end
    form:set_timeout(300000) -- 300s
    local upload_data = {}
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
                    upload_data[upkey] = { filename = filename }
                end
            end
        elseif typ == "body" then
            local file_info = upload_data[upkey] or {}
            file_info.value = res
            file_info.flen = tonumber(string.len(res))
            upload_data[upkey] = file_info
        elseif typ == "part_end" then
            ngx.log(ngx.DEBUG, "file[", upkey, "] upload success.")
        elseif typ == "eof" then
            break
        end
    end
    self.upload_data = upload_data
end

function Request:get_request_body()
    if self.request_body then
        return self.request_body
    end
    ngx.req.read_body()
    --self.request_body = ngx.var.request_body
    self.request_body = ngx.req.get_body_data()
    if self.request_body then
        return self.request_body
    end
    -- body may get buffered in a temp file:
    local body_file = ngx.req.get_body_file()
    if body_file then
        ngx.log(logger.i("body is in file ", tostring(body_file)))
        local body_file_handle, err = io.open(body_file, "r")
        if body_file_handle then
            body_file_handle:seek("set")
            self.request_body = body_file_handle:read("*a")
            body_file_handle:close()
        else
            self.request_body = ""
            ngx.log(logger.e("failed to open ", tostring(body_file), "for reading: ", tostring(err)))
        end
    else
        self.request_body = ""
        ngx.log(logger.i("no body found"))
    end
    return self.request_body
end

function Request:get_header(key, default)
    if not self.headers then
        return default
    end
    return self.headers[key] or default
end

function Request:get_ip()
    return self:get_header("X-Forwarded-For") or self:get_header("X-Real-IP", self.remote_addr)
end

--[[
 获取多个header，返回一个table
 eg. request: get_header_table("appkey","devid","devmac")
 retrun {appkey="aa", devid="bb", devmac="cc"} 
--]]
function Request:get_header_table(...)
    if not self.headers then
        return {}
    end
    return _.pick(self.headers, ...)
end

function Request:get_cookie(key, decrypt)
    local value = ngx.var['cookie_' .. key]
    if value and value ~= "" and decrypt == true then
        value = ndk.set_var.set_decode_base64(value)
        value = ndk.set_var.set_decrypt_session(value)
    end
    return value
end

function Request:rewrite(uri, jump)
    return ngx.req.set_uri(uri, jump)
end

return Request

