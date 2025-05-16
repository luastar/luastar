--[[
    字符串工具
--]]
local ngx = require "ngx"

local _M = {}

_M.null = "null"

-- 去除字符串前后空格
function _M.trim(str)
  if not str then return nil end
  return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

-- 字符串分隔
function _M.split(str, sep)
  local result = {}
  if not str or str == "" then return result end
  local regex = ("([^%s]+)"):format(sep)
  for each in str:gmatch(regex) do
    table.insert(result, each)
  end
  return result
end

-- 字符串忽略大小写比较是否相等
function _M.equals_ignore_case(str1, str2)
  if str1 == str2 then
    return true
  end
  if str1 and str2 and string.upper(str1) == string.upper(str2) then
    return true
  end
  return false
end

-- 字符串忽略大小写比较是否包含
function _M.contains_ignore_case(str1, str2)
  if str1 == str2 then
    return true
  end
  if str1 and str2 and ngx.re.find(str1, str2, "joi") ~= nil then
    return true
  end
  return false
end

-- 字符串是否以某个字符串开头
function _M.start_with(str, substr)
  if str == nil or substr == nil then
    return false
  end
  if ngx.re.find(str, substr, "joi") ~= 1 then
    return false
  else
    return true
  end
end

-- 字符串是否以某个字符串结尾
function _M.end_with(str, substr)
  if str == nil or substr == nil then
    return false
  end
  return _M.start_with(string.reverse(str), string.reverse(substr))
end

-- 字符串匹配
function _M.index_of(str, substr)
  return string.find(str, substr, 1, true)
end

-- 字符串反向匹配
function _M.last_index_of(str, substr)
  return string.match(str, '.*()' .. substr)
end

-- 请求链接是否匹配
function _M.path_is_macth(path_req, path_config, mode)
  return _M.path_and_method_is_macth(path_req, "*", path_config, "*", mode)
end

-- 请求链接和方法是否匹配
function _M.path_and_method_is_macth(path_req, method_req, path_config, method_config, mode)
  -- cjson 编码后会把 / 转义成 \/，需要替换回来
  local path_config = string.gsub(path_config, "\\/", "/")
  if mode == "v" then
    -- 模糊匹配
    if _M.contains_ignore_case(method_config, "*")
        or _M.contains_ignore_case(method_config, method_req) then
      local is, ie = string.find(path_req, path_config)
      if is ~= nil then
        return true
      end
    end
  else
    -- 精确匹配
    if _M.contains_ignore_case(method_config, "*")
        or _M.contains_ignore_case(method_config, method_req) then
      if path_req == path_config or path_req == (path_config .. "/") then
        return true
      end
    end
  end
  return false
end

-- 生成指定长度的随机字符串
function _M.random_str(len)
  local resty_random = require "resty.random"
  local resty_str = require "resty.string"
  return resty_str.to_hex(resty_random.bytes(len, true))
end

-- 格式化字符串
function _M.fmt_string(str, data)
  -- 找出所有${}变量
  local varAry = {}
  for word in string.gmatch(str, "%${[%w_]+}") do
    local var = string.sub(word, 3, string.len(word) - 1) -- sub ${}
    table.insert(varAry, var)
  end
  -- 替换变量
  for i, key in ipairs(varAry) do
    local value = data[key]
    if value ~= nil then
      value = string.gsub(tostring(value), "%%", "%%%%")
      str = string.gsub(str, "${" .. key .. "}", value)
    end
  end
  return str
end

-- 链接编码
function _M.encode_url(str)
  return ngx.escape_uri(str)
end

-- 链接解码
function _M.decode_url(str)
  return ngx.unescape_uri(str)
end

-- base64编码
function _M.encode_base64(str)
  return ngx.encode_base64(str)
end

-- base64解码
function _M.decode_base64(str)
  return ngx.decode_base64(str)
end

-- md5
function _M.md5(str)
  return ngx.md5(str)
end

-- sha1
function _M.sha1(str)
  local resty_str = require("resty.string")
  return resty_str.to_hex(ngx.sha1_bin(str))
end

-- hmac_sha1
function _M.hmac_sha1(secret_key, str)
  local resty_str = require("resty.string")
  return resty_str.to_hex(ngx.hmac_sha1(secret_key, str))
end

-- sha256
function _M.sha256(str)
  local resty_sha256 = require "resty.sha256"
  local resty_str = require "resty.string"
  local sha256 = resty_sha256:new()
  sha256:update(str)
  return resty_str.to_hex(sha256:final())
end

return _M
