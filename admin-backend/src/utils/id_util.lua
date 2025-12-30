--[[
@see https://github.com/Olivine-Labs/resty-mongol/blob/master/src/object_id.lua

 A BSON ObjectID is a 12-byte value consisting of
 a 4-byte timestamp (seconds since epoch),
 a 3-byte machine id,
 a 2-byte process id,
 and a 3-byte counter.

 Note that the timestamp and counter fields must be stored big endian unlike the rest of BSON
--]]
local ngx = require "ngx"

local _M = {}

--[[
将 ObjectID 转换为十六进制字符串表示形式。
@param ob - 包含 `id` 字段的 ObjectID 对象，`id` 是一个 12 字节的字符串。
@return string - 由 24 个十六进制字符组成的字符串，表示 ObjectID。
--]]
local function _tostring(ob)
  local t = {}
  for i = 1, 12 do
    -- 将每个字节转换为两位十六进制字符串并插入表中
    table.insert(t, string.format("%02x", string.byte(ob.id, i, i)))
  end
  return table.concat(t)
end

--[[
将小端字节序的无符号整数转换为 Lua 数字。
@param s - 包含字节数据的字符串。
@param i (optional) - 起始字节索引，默认为 1。
@param j (optional) - 结束字节索引，默认为字符串的长度。
@return number - 转换后的 Lua 数字。
--]]
local le_uint_to_num = function(s, i, j)
  i, j = i or 1, j or #s
  local b = { string.byte(s, i, j) }
  local n = 0
  for i = #b, 1, -1 do
    n = n * 2 ^ 8 + b[i]
  end
  return n
end

--[[
将小端字节序的有符号整数转换为 Lua 数字。
@param s - 包含字节数据的字符串。
@param i (optional) - 起始字节索引，默认为 1。
@param j (optional) - 结束字节索引，默认为字符串的长度。
@return number - 转换后的 Lua 数字。
--]]
local le_int_to_num = function(s, i, j)
  i, j = i or 1, j or #s
  local n = le_uint_to_num(s, i, j)
  local overflow = 2 ^ (8 * (j - i) + 7)
  if n > 2 ^ overflow then
    n = -(n % 2 ^ overflow)
  end
  return n
end

--[[
将 Lua 数字转换为小端字节序的无符号整数字节串。
@param n - 要转换的 Lua 数字。
@param bytes (optional) - 字节数，默认为 4。
@return string - 包含小端字节序的无符号整数的字符串。
--]]
local num_to_le_uint = function(n, bytes)
  bytes = bytes or 4
  local b = {}
  for i = 1, bytes do
    b[i], n = n % 2 ^ 8, math.floor(n / 2 ^ 8)
  end
  -- assert(n == 0)
  return string.char(unpack(b))
end

--[[
将 Lua 数字转换为小端字节序的有符号整数字节串。
@param n - 要转换的 Lua 数字。
@param bytes (optional) - 字节数，默认为 4。
@return string - 包含小端字节序的有符号整数的字符串。
--]]
local num_to_le_int = function(n, bytes)
  bytes = bytes or 4
  if n < 0 then
    -- Converted to unsigned.
    n = 2 ^ (8 * bytes) + n
  end
  return num_to_le_uint(n, bytes)
end

--[[
将大端字节序的无符号整数转换为 Lua 数字。
@param s - 包含字节数据的字符串。
@param i (optional) - 起始字节索引，默认为 1。
@param j (optional) - 结束字节索引，默认为字符串的长度。
@return number - 转换后的 Lua 数字。
--]]
local be_uint_to_num = function(s, i, j)
  i, j = i or 1, j or #s
  local b = { string.byte(s, i, j) }
  local n = 0
  for i = 1, #b do
    n = n * 2 ^ 8 + b[i]
  end
  return n
end

--[[
将 Lua 数字转换为大端字节序的无符号整数字节串。
@param n - 要转换的 Lua 数字。
@param bytes (optional) - 字节数，默认为 4。
@return string - 包含大端字节序的无符号整数的字符串。
--]]
local num_to_be_uint = function(n, bytes)
  bytes = bytes or 4
  local b = {}
  for i = bytes, 1, -1 do
    b[i], n = n % 2 ^ 8, math.floor(n / 2 ^ 8)
  end
  -- assert(n == 0)
  return string.char(unpack(b))
end

--[[
从 ObjectID 中提取时间戳。
@param ob - 包含 `id` 字段的 ObjectID 对象，`id` 是一个 12 字节的字符串。
@return number - 从 ObjectID 中提取的时间戳（自纪元以来的秒数）。
--]]
local function _get_ts(ob)
  return be_uint_to_num(ob.id, 1, 4)
end

--[[
从 ObjectID 中提取机器 ID 的十六进制表示形式。
@param ob - 包含 `id` 字段的 ObjectID 对象，`id` 是一个 12 字节的字符串。
@return string - 由 6 个十六进制字符组成的字符串，表示机器 ID。
--]]
local function _get_hostname(ob)
  local t = {}
  for i = 5, 7 do
    table.insert(t, string.format("%02x", string.byte(ob.id, i, i)))
  end
  return table.concat(t)
end

--[[
从 ObjectID 中提取进程 ID。
@param ob - 包含 `id` 字段的 ObjectID 对象，`id` 是一个 12 字节的字符串。
@return number - 从 ObjectID 中提取的进程 ID。
--]]
local function _get_pid(ob)
  return be_uint_to_num(ob.id, 8, 9)
end

--[[
从 ObjectID 中提取递增计数器的值。
@param ob - 包含 `id` 字段的 ObjectID 对象，`id` 是一个 12 字节的字符串。
@return number - 从 ObjectID 中提取的递增计数器的值。
--]]
local function _get_inc(ob)
  return be_uint_to_num(ob.id, 10, 12)
end

--[[
ObjectID 对象的元表，定义了对象的一些元方法。
@field __tostring - 当使用 `tostring()` 函数处理 ObjectID 对象时调用的函数。
@field __eq - 当使用 `==` 运算符比较两个 ObjectID 对象时调用的函数。
--]]
local object_id_mt = {
  __tostring = _tostring,
  __eq = function(a, b) return a.id == b.id end,
}

-- 通过系统命令获取机器的主机名
local machineid = assert(io.popen("uname -n")):read("*l")
machineid = ngx and ngx.md5_bin(machineid):sub(1, 3) or require("md5").sum(machineid):sub(1, 3)

-- 初始化递增计数器
local inc = 0

--[[
生成一个新的 12 字节的 ObjectID。
@return string - 一个 12 字节的字符串，表示新生成的 ObjectID。
--]]
local function generate_id()
  local pid = ngx and num_to_le_uint(ngx.var.pid, 2) or num_to_le_uint(1, 2)
  inc = inc + 1
  return num_to_be_uint(os.time(), 4) .. machineid .. pid .. num_to_be_uint(inc, 3)
end

--[[
创建一个新的 ObjectID 对象。
@param str (optional) - 一个 12 字节的字符串，表示 ObjectID。如果未提供，则生成一个新的 ObjectID。
@return table - 一个新的 ObjectID 对象，包含多个方法用于访问其组成部分。
--]]
function _M.new_object_id(str)
  if str then
    assert(#str == 12)
  else
    str = generate_id()
  end
  return setmetatable({
    id = str,
    tostring = _tostring,
    get_ts = _get_ts,
    get_pid = _get_pid,
    get_hostname = _get_hostname,
    get_inc = _get_inc,
  }, object_id_mt)
end

--[[
创建一个新的 id 字符串
--]]
function _M.new_id()
  return _M.new_object_id():tostring()
end

return _M
