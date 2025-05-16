--[===[
  配置管理模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
  获取配置列表
--]]
function _M.get_config_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取配置列表
  local config_service = module.require("service.config")
  local call_err = ""
  local ok, count, list = xpcall(function()
    return config_service.get_config_count_and_list(params)
  end, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  local data = {
    total = count,
    list = list
  }
  ngx.ctx.response:writeln(res_util.success(data))
end

--[[
  获取配置信息
--]]
function _M.get_config_info()
  -- 获取查询参数
  local id = ngx.ctx.request:get_arg("id")
  -- 从数据库获取配置信息
  local config_service = module.require("service.config")
  local call_err = ""
  local ok, config_info = xpcall(config_service.get_config_by_id, function(err)
    call_err = error_util.get_msg(err)
  end, id)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(config_info))
end

--[[
  创建配置
--]]
function _M.create_config()
  -- 获取请求参数
  local params = ngx.ctx.request:get_body_json()
  -- 创建配置
  local config_service = module.require("service.config")
  local call_err = ""
  local ok, id = xpcall(config_service.create_config, function(err)
    call_err = error_util.get_msg(err)
  end, params)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(id))
end

--[[
  更新配置
--]]
function _M.update_config()
  -- 获取请求参数
  local params = ngx.ctx.request:get_body_json()
  -- 更新配置
  local config_service = module.require("service.config")
  local call_err = ""
  local ok = xpcall(config_service.update_config, function(err)
    call_err = error_util.get_msg(err)
  end, params)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  删除配置
--]]
function _M.delete_config()
  -- 获取请求参数
  local params = ngx.ctx.request:get_body_json()
  local ids = params["ids"]
  -- 参数校验
  if _.isEmpty(ids) then
    ngx.ctx.response:writeln(res_util.failure("参数[ids]不能为空"))
    return
  end
  -- 删除配置
  local config_service = module.require("service.config")
  local call_err = ""
  local ok = xpcall(config_service.delete_config, function(err)
    call_err = error_util.get_msg(err)
  end, ids)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  获取配置内容
--]]
function _M.get_config_content()
  -- 获取查询参数
  local code = ngx.ctx.request:get_arg("code")
  -- 从数据库获取配置信息
  local config_service = module.require("service.config")
  local call_err = ""
  local ok, config_info = xpcall(config_service.get_config_by_code, function(err)
    call_err = error_util.get_msg(err)
  end, code)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  if not config_info then
    ngx.ctx.response:writeln(res_util.success())
    return
  end
  -- 返回结果
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
  ngx.ctx.response:writeln(res_util.success(data))
end

return _M
