--[[
代码模块
--]]
local ngx = require "ngx"
local file_util = require "utils.file_util"
local str_util = require "utils.str_util"
local error_util = require "utils.error_util"

local _M = {}

--[===[
加载模块代码
--]===]
function _M.require(mcode)
  -- 从字典中获取模块信息
  local dict = ngx.shared.dict_ls_modules
  local module_content_base64 = dict:get(mcode)
  if module_content_base64 then
    -- 加载模块代码
    local module_content = str_util.decode_base64(module_content_base64)
    return file_util.load_lua_str(module_content)
  end
  -- 从本地项目加载模块
  local ok, module = pcall(require, "modules." .. mcode)
  if ok then
    return module
  end
  error_util.throw("模块[" .. mcode .. "]不存在！")
end

--[===[
执行模块方法
--]===]
function _M.execute(mcode, mfunc, params)
  if _.isEmpty(mcode) or _.isEmpty(mfunc) then
    return false, "模块编码或方法名不能为空！"
  end
  -- 加载模块代码
  local ok, module = pcall(_M.require, mcode)
  if not ok then
    return false, "模块[" .. mcode .. "]加载失败！"
  end
  -- 执行模块方法
  if not module[mfunc] then
    return false, "模块方法[" .. mcode .. "][" .. mfunc .. "]不存在！"
  end
  return pcall(module[mfunc], params)
end

return _M
