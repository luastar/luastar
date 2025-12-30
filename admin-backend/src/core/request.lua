--[[
	http 请求模块
--]]
local ngx = require "ngx"
local ndk = require "ndk"
local upload = require "resty.upload"

local _M = {}
local mt = { __index = _M }

-- 构造函数
function _M:new()
  logger.debug("[Request init] start.")
  local instance = {
    schema = ngx.var.schema,
    host = ngx.var.host,
    server_addr = ngx.var.server_addr,
    server_port = ngx.var.server_port,
    uri = ngx.var.uri,
    request_method = ngx.var.request_method,
    request_uri = ngx.var.request_uri,
    query_string = ngx.var.query_string,
    content_type = ngx.var.content_type,
    headers_init = false,
    headers = nil,
    uri_args_init = false,
    uri_args = nil,
    json_args_init = false,
    json_args = nil,
    post_args_init = false,
    post_args = nil,
    multipart_args_init = false,
    multipart_args = nil,
    body_init = false,
    body = nil,
    body_json_init = false,
    body_json = nil
  }
  return setmetatable(instance, mt)
end

-- 是否 form-data 请求（表单 + 文件）
function _M:is_multipart()
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

-- 是否 json 请求
function _M:is_json()
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

-- 获取各种参数
function _M:get_arg(name, default)
  -- 优先从 query 获取
  local arg = self:get_query_arg(name)
  if arg then
    return arg
  end
  if self:is_multipart() then
    return self:get_multipart_arg(name, default)
  elseif self:is_json() then
    return self:get_json_arg(name, default)
  else
    return self:get_form_arg(name, default)
  end
end

-- 获取 query 参数
function _M:get_query_arg(name, default)
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

-- 获取post表单参数
function _M:get_form_arg(name, default)
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

-- 获取 form-data 参数
function _M:get_multipart_arg(name, default)
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

-- 读取 form-data 参数
function _M:init_multipart_args()
  local form, err = upload:new(8192)
  if not form then
    logger.error("failed to new upload: ", err)
    return
  end
  form:set_timeout(120000) -- 120s
  local multipart_args = {}
  local upkey, filename = nil, nil
  while true do
    local typ, res, err = form:read()
    if not typ then
      logger.debug("failed to read: ", err)
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
      logger.debug("file[", upkey, "] upload success.")
    elseif typ == "eof" then
      break
    end
  end
  self.multipart_args = multipart_args
end

-- 获取路径参数
function _M:get_path_arg(pattern)
  -- 预处理路径（去除开头和结尾的斜杠，合并连续斜杠）
  local uri_path = self.uri:gsub("^/+", ""):gsub("/+$", ""):gsub("//+", "/")
  local uri_pattern = pattern:gsub("^/+", ""):gsub("/+$", ""):gsub("//+", "/")
  -- 分割路径和模式为段
  local path_segments = {}
  for seg in uri_path:gmatch("[^/]+") do
    table.insert(path_segments, seg)
  end
  local pattern_segments = {}
  for seg in uri_pattern:gmatch("[^/]+") do
    table.insert(pattern_segments, seg)
  end
  -- 检查路径和模式的段数量是否匹配
  if #path_segments ~= #pattern_segments then
    return nil
  end
  -- 提取参数
  local args = {}
  for i, pattern_seg in ipairs(pattern_segments) do
    -- 提取参数值
    local path_seg = path_segments[i]
    -- 检查是否为参数占位符（例如 {id}）
    local arg_name = pattern_seg:match("^{([^}]+)}$")
    if arg_name then
      args[arg_name] = path_seg
    else
      -- 静态段必须完全匹配
      if pattern_seg ~= path_seg then
        return nil
      end
    end
  end
  return args
end

-- 获取请求体
function _M:get_body()
  -- 初始化
  if not self.body_init then
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    if body then
      self.body = body
    else
      -- body may get buffered in a temp file
      local body_file = ngx.req.get_body_file()
      if body_file then
        logger.info("body is in file ", tostring(body_file))
        local body_file_handle, err = io.open(body_file, "r")
        if body_file_handle then
          body_file_handle:seek("set")
          body = body_file_handle:read("*a")
          body_file_handle:close()
          self.body = body
        else
          logger.error("failed to open ", tostring(body_file), "for reading: ", tostring(err))
          self.body = ""
        end
      else
        self.body = ""
      end
    end
    self.body_init = true
  end
  return self.body
end

-- 获取请求体，并且转成 json
function _M:get_body_json()
  -- 初始化
  if not self.body_json_init then
    local body = self:get_body()
    if not _.isEmpty(body) then
      local call_ok, body_json = pcall(cjson.decode, body)
      if call_ok then
        self.body_json = body_json
      end
    end
    self.body_json_init = true
  end
  return self.body_json
end

-- 获取 表体 json 参数
function _M:get_json_arg(name, default)
  if not name then
    return default
  end
  local body_json = self:get_body_json()
  if not body_json then
    return default
  end
  return body_json[name] or default
end

-- 获取 请求头
function _M:get_header(name, default)
  if not self.headers_init then
    self.headers = ngx.req.get_headers()
    self.headers_init = true
  end
  if not self.headers then
    return default
  end
  return self.headers[name] or default
end

-- 获取 请求头 中的最后一个值
function _M:get_header_single(name, default)
  local header_value = self:get_header(name, default)
  if _.isArray(header_value) then
    return header_value[#header_value]
  end
  return header_value
end

--[[
 获取多个header，返回一个table
 eg. request: get_header_table("appkey","devid","devmac")
 retrun {appkey="aa", devid="bb", devmac="cc"}
--]]
function _M:get_header_table(...)
  if not self.headers_init then
    self.headers = ngx.req.get_headers()
    self.headers_init = true
  end
  if not self.headers then
    return {}
  end
  return _.pick(self.headers, ...)
end

-- 获取 ip
function _M:get_ip()
  return self:get_header("X-Forwarded-For") or self:get_header("X-Real-IP", self.remote_addr)
end

-- 获取 cookie
function _M:get_cookie(name, decrypt)
  local value = ngx.var["cookie_" .. name]
  if value and value ~= "" and decrypt == true then
    value = ndk.set_var.set_decode_base64(value)
    value = ndk.set_var.set_decrypt_session(value)
  end
  return value
end

return _M
