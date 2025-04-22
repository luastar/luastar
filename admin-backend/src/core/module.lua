--[[
代码模块
--]]
local ngx = require "ngx"
local file_util = require "utils.file_util"
local str_util = require "utils.str_util"

local _M = {}

--[===[
加载模块代码
--]===]
function _M.require(mid)
  -- 从字典中获取模块信息
  local dict = ngx.shared.dict_ls_modules;
  local module_info_str = dict:get(mid);
  if not module_info_str then
    error("模块[" .. mid .. "]不存在！")
  end
  -- 加载模块代码
  local module_info = cjson.decode(module_info_str);
  local module_content = str_util.decode_base64(module_info.content);
  return file_util.load_lua_str(module_content);
end

--[===[
执行模块方法
--]===]
function _M.execute(mid, mfunc, params)
  if _.isEmpty(mid) or _.isEmpty(mfunc) then
    return false, "模块id或方法名不能为空！"
  end
  -- 加载模块代码
  local ok, module = pcall(_M.require, mid);
  if not ok then
    return false, module;
  end
  -- 执行模块方法
  if not module[mfunc] then
    return false, "模块[" .. mid .. "]不存在方法[" .. mfunc .. "]！"
  end
  return pcall(module[mfunc], params)
end

return _M
