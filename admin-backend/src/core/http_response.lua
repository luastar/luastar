--[[
	http 响应模块
--]]
local ngx = ngx

local _M = {}
local mt = { __index = _M }

-- 初始化
function _M.new(self)
    logger.debug("[Response init] start.")
    local instance = {
        _output = {},
        _cookies = {},
        _eof = false
    }
    return setmetatable(instance, mt)
end

-- 写入内容
function _M:write(content)
    if self._eof then
        logger.error("response has been explicitly finished before.")
        return
    end
    table.insert(self._output, content)
end

-- 写入内容并换行
function _M:writeln(content)
    if self._eof then
        logger.error("response has been explicitly finished before.")
        return
    end
    table.insert(self._output, content)
    table.insert(self._output, "\r\n")
end

-- 获取输出内容
function _M:get_output()
    return self._output
end

-- 重置输出内容
function _M:reset_output()
    self._output = {}
end

-- 重定向
function _M:redirect(url, status)
    ngx.redirect(url, status)
end

-- 设置返回 http 状态
function _M:set_status(status)
    local res_status = tonumber(status)
    if _.isEmpty(res_status) then
        logger.error("response res_status is empty.")
        return
    end
    ngx.status = res_status
end

-- 设置返回头
function _M:set_header(name, value)
    if _.isEmpty(name) or _.isEmpty(value) then
        return
    end
    ngx.header[name] = value
end

-- 设置返回头（多个）
function _M:set_headers(headers)
    if _.isEmpty(headers) then
        return
    end
    for k, v in pairs(headers) do
        self:set_header(k, v)
    end
end

-- 设置返回格式为文本
function _M:set_content_type_plain()
    self:set_header("Content-Type", "text/plain; charset=utf-8")
end

-- 设置返回格式为html
function _M:set_content_type_html()
    self:set_header("Content-Type", "text/html; charset=utf-8")
end

-- 设置返回格式为json
function _M:set_content_type_json()
    self:set_header("Content-Type", "application/json; charset=utf-8")
end

-- 设置返回格式为文件下载
function _M:set_content_type_stream()
    self:set_header("Content-Type", "application/octet-stream; charset=utf-8")
end

-- 设置 cookie
local function _set_cookie_(key, value, encrypt, duration, path)
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

-- 设置 cookie
function _M:set_cookie(key, value, encrypt, duration, path)
    local cookie = _set_cookie_(key, value, encrypt, duration, path)
    self._cookies[key] = cookie
    self:set_header("Set-Cookie", _.values(self._cookies))
end

-- 设置为 500 错误
function _M:error(info)
    if self._eof then
        logger.error("response has been explicitly finished before.")
        return
    end
    self:set_status(500)
    self:set_content_type_html()
    self:write(info)
end

-- 结束返回
function _M:finish()
    if self._eof then
        logger.error("response has been explicitly finished before.")
        return
    end
    ngx.print(self._output)        -- 输出
    self._output = nil             -- 清空内容
    self._eof = true               -- 标记结束
    local ok, ret = pcall(ngx.eof) -- 返回结束
    if not ok then
        logger.error("ngx.eof() error:" .. ret)
    end
end

return _M
