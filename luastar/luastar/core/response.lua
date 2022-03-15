--[[
	响应类
--]]
local Response = luastar_class("luastar.core.Response")

function Response:init()
    ngx.log(ngx.DEBUG, "[Response:init] start.")
    self._output = {}
    self._cookies = {}
    self._eof = false
end

function Response:write(content)
    if self._eof then
        ngx.log(ngx.ERR, "response has been explicitly finished before.")
        return
    end
    table.insert(self._output, content)
end

function Response:writeln(content)
    if self._eof then
        ngx.log(ngx.ERR, "response has been explicitly finished before.")
        return
    end
    table.insert(self._output, content)
    table.insert(self._output, "\r\n")
end

function Response:get_output()
    return self._output
end

function Response:reset_output()
    self._output = {}
end

function Response:redirect(url, status)
    ngx.redirect(url, status)
end

function Response:set_status(status)
    local res_status = tonumber(status)
    if _.isEmpty(res_status) then
        ngx.log(ngx.ERR, "response res_status is empty.")
        return
    end
    ngx.status = res_status
end

function Response:set_header(name, value)
    if _.isEmpty(name) or _.isEmpty(value) then
        return
    end
    ngx.header[name] = value
end

function Response:set_headers(headers)
    if _.isEmpty(headers) then
        return
    end
    for k, v in pairs(headers) do
        self:set_header(k, v)
    end
end

function Response:set_content_type_plain()
    self:set_header("Content-Type", "text/plain; charset=utf-8")
end

function Response:set_content_type_html()
    self:set_header("Content-Type", "text/html; charset=utf-8")
end

function Response:set_content_type_json()
    self:set_header("Content-Type", "application/json; charset=utf-8")
end

function Response:set_content_type_stream()
    self:set_header("Content-Type", "application/octet-stream; charset=utf-8")
end

function Response:set_cookie(key, value, encrypt, duration, path)
    local cookie = self:_set_cookie(key, value, encrypt, duration, path)
    self._cookies[key] = cookie
    self:set_header("Set-Cookie", _.values(self._cookies))
end

function Response:_set_cookie(key, value, encrypt, duration, path)
    if not value then return nil end
    if not key or key == "" or not value then
        return
    end
    if not duration or duration <= 0 then
        duration = 604800 -- 7 days, 7*24*60*60 seconds
    end
    if not path or path == "" then
        path = "/"
    end
    if value and value ~= "" and encrypt == true then
        value = ndk.set_var.set_encrypt_session(value)
        value = ndk.set_var.set_encode_base64(value)
    end
    local expiretime = ngx.time() + duration
    expiretime = ngx.cookie_time(expiretime)
    return table.concat({ key, "=", value, "; expires=", expiretime, "; path=", path })
end

function Response:error(info)
    if self._eof then
        ngx.log(ngx.ERR, "response has been explicitly finished before.")
        return
    end
    self:set_status(500)
    self:set_content_type_html()
    self:write(info)
end

function Response:finish()
    if self._eof then
        ngx.log(ngx.ERR, "response has been explicitly finished before.")
        return
    end
    ngx.print(self._output) -- 输出
    self._output = nil -- 清空内容
    self._eof = true -- 标记结束
    local ok, ret = pcall(ngx.eof) -- 关闭链接
    if not ok then
        ngx.log(ngx.ERR, "ngx.eof() error:" .. ret)
    end
end

return Response