--[[
配置模块
--]]
local ngx = require "ngx"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local _M = {}

function _M.get_config(code)
  -- 参数判断
  if _.isEmpty(code) then
    error_util.throw("配置编码不能为空！")
  end
  -- 从字典中获取配置信息
  local dict = ngx.shared.dict_ls_configs
  local config_info_str = dict:get(code)
  if not config_info_str then
    error_util.throw("配置[" .. code .. "]不存在！")
  end
  local config_info = cjson.decode(config_info_str)
  local vtype = config_info["vtype"]
  local vcontent = config_info["vcontent"]
  local data = vcontent
  if vtype == enum_util.CONFIG_VTYPE.NUMBER then
    data = tonumber(vcontent)
  elseif vtype == enum_util.CONFIG_VTYPE.BOOLEAN then
    data = _.toBoolean(vcontent)
  elseif vtype == enum_util.CONFIG_VTYPE.OBJECT
      or vtype == enum_util.CONFIG_VTYPE.ARRAY then
    data = cjson.decode(vcontent)
  end
  return data
end

return _M
