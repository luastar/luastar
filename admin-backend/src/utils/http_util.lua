--[[
    http 客户端工具
--]]
local ngx = require "ngx"
local http = require "resty.http"

local _M = {}

-- 私有方法
-- 格式化字符串
local fmt = function(p, ...)
  if select("#", ...) == 0 then
    return p
  else
    return string.format(p, ...)
  end
end

-- 私有方法
-- 表中添加一个格式化的字符串
local tprintf = function(t, p, ...)
  t[#t + 1] = fmt(p, ...)
end

-- 私有方法
-- 追加文件数据
local append_data = function(r, k, data, extra)
  tprintf(r, "content-disposition: form-data; name=\"%s\"", k)
  if extra.filename then
    tprintf(r, "; filename=\"%s\"", extra.filename)
  end
  if extra.content_type then
    tprintf(r, "\r\ncontent-type: %s", extra.content_type)
  end
  if extra.content_transfer_encoding then
    tprintf(r, "\r\ncontent-transfer-encoding: %s", extra.content_transfer_encoding)
  end
  tprintf(r, "\r\n\r\n")
  tprintf(r, data)
  tprintf(r, "\r\n")
end

-- 私有方法
-- 将请求参数编码为 multipart/form-data 格式
local encode_form_data_params = function(t, boundary)
  local r = {}
  local _t
  for k, v in pairs(t) do
    tprintf(r, "--%s\r\n", boundary)
    _t = type(v)
    if _t == "string" then
      append_data(r, k, v, {})
    elseif _t == "table" then
      assert(v.data or v.value, "invalid input")
      local extra = {
        filename = v.filename or v.name,
        content_type = v.content_type or v.mimetype or "application/octet-stream",
        content_transfer_encoding = v.content_transfer_encoding or "binary",
      }
      append_data(r, k, v.data or v.value, extra)
    else
      error(string.format("unexpected type %s", _t))
    end
  end
  tprintf(r, "--%s--\r\n", boundary)
  return table.concat(r)
end

-- 私有方法
-- 判断是否包含文件
local hasfile = function(t)
  local has_file = false
  for k, v in pairs(t) do
    if type(v) == "table" then
      has_file = true
      break
    end
  end
  return has_file
end

-- 私有方法
-- 生成随机的 boundary
local gen_boundary = function()
  local t = { "BOUNDARY-" }
  for i = 2, 17 do
    t[i] = string.char(math.random(65, 90))
  end
  t[18] = "-BOUNDARY"
  return table.concat(t)
end

-- 公有方法
-- 将请求参数编码为 application/x-www-form-urlencoded 格式
function _M.encode_form_params(t)
  local body = {}
  for k, v in pairs(t) do
    body[#body + 1] = k .. "=" .. v
  end
  return table.concat(body, "&")
end

-- 公有方法
-- 参数编码
function _M.encode_params(t)
  local body, content_type
  if hasfile(t) then
    local boundary = gen_boundary()
    body = encode_form_data_params(t, boundary)
    content_type = fmt("multipart/form-data; boundary=%s", boundary)
  else
    body = _M.encode_form_params(t)
    content_type = "application/x-www-form-urlencoded"
  end
  return body, content_type
end

--[===[
请求参数：
{
    url = "", -- 请求链接
    method = "POST", -- http方法, 默认：GET
    headers = { content-type="application/x-www-form-urlencoded" }, -- 请求头信息
    params = { a="1", b="2" }, -- 请求参数
    body = "", -- 请求体
    connect_timeout = 6000, -- 连接超时时间
    send_timeout = 600000, -- 发送超时时间
    read_timeout = 600000, -- 读取超时时间
    keepalive = true, -- 是否保持连接
    keepalive_timeout = 600000, -- 连接池超时时间
    keepalive_pool = 256 -- 连接池大小
}
返回结果：{ status, headers, body }
--]===]
function _M.request(options)
  -- 参数校验
  if _.isEmpty(options)
      or not _.isTable(options)
      or _.isEmpty(options["url"]) then
    return nil, "参数错误！"
  end
  -- 设置默认值
  options = _.defaults(options, {
    method = "GET",
    headers = {},
    connect_timeout = 6000,
    send_timeout = 600000,
    read_timeout = 600000,
    keepalive = true,
    keepalive_timeout = 600000, -- 单位是ms
    keepalive_pool = 256
  })
  -- 设置 trace_id
  options["headers"]["trace_id"] = ngx.ctx.trace_id
  -- 处理参数和头信息
  if not _.isEmpty(options["params"]) then
    if options["method"] == "GET" then
      local query_string = _M.encode_form_params(options["params"])
      local pos_s, pos_e = string.find(options["url"], "?")
      if pos_s == nil then
        options["url"] = options["url"] .. "?" .. query_string
      else
        options["url"] = options["url"] .. "&" .. query_string
      end
    else
      local body, content_type = _M.encode_params(options["params"])
      options["body"] = body
      options["headers"]["Content-Type"] = content_type
    end
  end
  -- 发起 http 请求
  local httpc = http:new()
  httpc:set_timeouts(options["connect_timeout"], options["send_timeout"], options["read_timeout"])
  local res, err = httpc:request_uri(options["url"], options)
  if not res then
    logger.error("request fail: ", err)
    return nil, err
  end
  return res
end

function _M.request_sse(options)
  -- 参数校验
  if _.isEmpty(options)
      or not _.isTable(options)
      or _.isEmpty(options["url"]) then
    return nil, "参数错误！"
  end
  -- 设置默认值
  options = _.defaults(options, {
    method = "GET",
    headers = {},
    callback = logger.info,
    connect_timeout = 6000,
    send_timeout = 600000,
    read_timeout = 600000,
    keepalive = true,
    keepalive_timeout = 600000, -- 单位是ms
    keepalive_pool = 256
  })
  -- 设置 trace_id
  options["headers"]["trace_id"] = ngx.ctx.trace_id
  -- 处理参数和头信息
  if not _.isEmpty(options["params"]) then
    if options["method"] == "GET" then
      local query_string = _M.encode_form_params(options["params"])
      local pos_s, pos_e = string.find(options["url"], "?")
      if pos_s == nil then
        options["url"] = options["url"] .. "?" .. query_string
      else
        options["url"] = options["url"] .. "&" .. query_string
      end
    else
      local body, content_type = _M.encode_params(options["params"])
      options["body"] = body
      options["headers"]["Content-Type"] = content_type
    end
  end
  -- 创建实例
  local httpc = http:new()
  httpc:set_timeouts(options["connect_timeout"], options["send_timeout"], options["read_timeout"])
  -- 解析连接
  do
    local parsed_uri, err = httpc:parse_uri(options["url"])
    if not parsed_uri then
      return nil, err
    end
    options["scheme"], options["host"], options["port"], options["path"], options["query"] = unpack(parsed_uri)
    options["ssl_server_name"] = options["ssl_server_name"] or options["port"]
  end
  -- 设置代理参数
  do
    local proxy_auth = options["headers"]["Proxy-Authorization"]
    if proxy_auth and options["proxy_opts"] then
      options["proxy_opts"]["https_proxy_authorization"] = proxy_auth
      options["proxy_opts"]["http_proxy_authorization"] = proxy_auth
    end
  end
  -- 创建连接
  local ok, err = httpc:connect(options)
  if not ok then
    logger.error("connection failed: ", err)
    return nil, err
  end
  -- 发送请求
  local res, err = httpc:request(options)
  if not res then
    logger.error("request failed: ", err)
    return nil, err
  end
  -- 读取结果
  local reader = res.body_reader
  repeat
    local buffer, err = reader(8192)
    if err then
      logger.error("read failed: ", err)
      break
    end
    if buffer then
      options["callback"](buffer)
    end
  until not buffer
  -- 关闭连接
  if options["keepalive"] == false then
    local ok, err = httpc:close()
    if not ok then
      logger.error("close failed: ", err)
    end
  else
    local ok, err = httpc:set_keepalive(options["keepalive_timeout"], options["keepalive_pool"])
    if not ok then
      logger.error("set_keepalive failed: ", err)
    end
  end
  return res, nil
end

return _M
