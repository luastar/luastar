--[===[
  路由管理模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
  获取配置内容
--]]
function _M.get_config_content()
  -- 获取查询参数
  local code = ngx.ctx.request:get_arg("code");
  -- 从数据库获取配置信息
  local config_service = module.require("service.config")
  local call_err = ""
  local ok, config_info = xpcall(config_service.get_config_by_code, function(err)
    call_err = error_util.get_msg(err)
  end, code);
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  if not config_info then
    ngx.ctx.response:writeln(res_util.success())
    return
  end
  -- 返回结果
  local vtype = config_info.vtype
  local vcontent = config_info.vcontent
  local data = vcontent
  if vtype == enum_util.CONFIG_VTYPE.NUMBER then
    data = tonumber(vcontent)
  elseif vtype == enum_util.CONFIG_VTYPE.BOOLEAN then
    data = _.toBoolean(vcontent)
  elseif vtype == enum_util.CONFIG_VTYPE.OBJECT
      or vtype == enum_util.CONFIG_VTYPE.ARRAY then
    data = cjson.decode(vcontent)
  end
  ngx.ctx.response:writeln(res_util.success(data));
end

return _M
