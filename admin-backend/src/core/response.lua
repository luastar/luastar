--[[
	http 响应模块
--]]
local ngx = require "ngx"
local ndk = require "ndk"

local _M = {}
local mt = { __index = _M }

-- 初始化
function _M.new(self)
  logger.debug("[Response init] start.")
  local instance = {
    _cookies = {}
  }
  return setmetatable(instance, mt)
end

-- 写入内容
function _M:write(content)
  ngx.print(content)
end

-- 写入内容并换行
function _M:writeln(content)
  ngx.say(content)
end

-- 刷新缓冲区
function _M:flush(wait)
  ngx.flush(wait)
end

-- 重定向
function _M:redirect(url, status)
  ngx.redirect(url, status)
end

-- 设置返回 http 状态
function _M:set_status(status)
  ngx.status = status
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
function _M:set_cookie(key, value, encrypt, duration, path)
  if _.isEmpty(key) or _.isEmpty(value) then
    return
  end
  if not duration or duration <= 0 then
    duration = 604800 -- 7 days, 7*24*60*60 seconds
  end
  if _.isEmpty(path) then
    path = "/"
  end
  if encrypt then
    value = ndk.set_var.set_encrypt_session(value)
    value = ndk.set_var.set_encode_base64(value)
  end
  local expiretime = ngx.cookie_time(ngx.time() + duration)
  self._cookies[key] = table.concat({ key, "=", value, "; expires=", expiretime, "; path=", path })
  self:set_header("Set-Cookie", _.values(self._cookies))
end

-- 删除 cookie
function _M:remove_cookie(key)
  if _.isEmpty(key) then
    return
  end
  self._cookies[key] = nil
  self:set_header("Set-Cookie", _.values(self._cookies))
end

-- 设置为 500 错误
function _M:error(info)
  self:set_status(ngx.HTTP_INTERNAL_SERVER_ERROR)
  self:set_content_type_html()
  self:write(info)
end

-- 结束返回
function _M:finish()
  -- ngx.eof()
  ngx.exit(ngx.HTTP_OK)
end

return _M
