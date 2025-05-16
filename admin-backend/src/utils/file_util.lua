--[[
	文件工具
--]]
local _M = {}

-- 加载LUA文件
function _M.load_lua(file)
  logger.info("加载LUA文件：", file)
  -- 加载指定路径下的Lua代码文件（不会执行）
  local fct = assert(loadfile(file))
  -- 设置全局环境变量
  local env = setmetatable({}, { __index = _G })
  setfenv(fct, env)
  -- 执行Lua文件中全局部分的代码
  local ok, res = assert(pcall(fct))
  return res
end

-- 加载LUA字符串
function _M.load_lua_str(str)
  logger.debug("加载LUA字符串：", str)
  local fct = assert(loadstring(str))
  -- 设置全局环境变量
  local env = setmetatable({}, { __index = _G })
  setfenv(fct, env)
  -- 执行Lua文件中全局部分的代码
  local ok, res = assert(pcall(fct))
  return res
end

-- 加载JSON文件
function _M.load_json(file)
  logger.info("加载JSON文件：", file)
  -- 读取文件内容
  local f = assert(io.open(file, "r"))
  local content = f:read("*a")
  f:close()
  -- 解析JSON内容
  local ok, result = pcall(require("cjson").decode, content)
  if not ok then
    logger.error("解析JSON文件失败：", result)
    return nil
  end
  return result
end

return _M
