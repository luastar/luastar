--[[
配置模块
--]]
local ngx = require "ngx"
local enum_util = require "utils.enum_util"

local _M = {}

function _M:get_config(cid)
  -- 从字典中获取配置信息
  local dict = ngx.shared.dict_ls_configs
  local config_info_str = dict:get(cid)
  if not config_info_str then
    error("配置[" .. cid .. "]不存在！")
  end
  local module_info = cjson.decode(config_info_str)
  if module_info["vtype"] == enum_util.config_vtype.STRING then
    return tostring(module_info["vcontent"])
  elseif module_info["vtype"] == enum_util.config_vtype.NUMBER then
    return tonumber(module_info["vcontent"])
  elseif module_info["vtype"] == enum_util.config_vtype.BOOLEAN then
    return _.toBoolean(module_info["vcontent"])
  else
    return cjson.decode(module_info["vcontent"])
  end
end

return _M
