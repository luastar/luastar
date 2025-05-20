--[===[
  代码管理模块
--]===]
local ngx = require "ngx"
local module = require "core.module"
local res_util = require "utils.res_util"
local error_util = require "utils.error_util"
local file_util = require "utils.file_util"

local _M = {}

--[[
  获取代码列表
--]]
function _M.get_module_list()
  -- 获取查询参数
  local params = ngx.ctx.request:get_body_json() or {}
  -- 从数据库获取代码列表
  local module_service = module.require("service.module")
  local call_err = ""
  local ok, count, list = xpcall(function()
    return module_service.get_module_count_and_list(params)
  end, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success({ total = count, list = list }))
end

--[[
  获取代码信息
--]]
function _M.get_module_info()
  -- 获取查询参数
  local id = ngx.ctx.request:get_arg("id")
  -- 从数据库获取代码信息
  local module_service = module.require("service.module")
  local call_err = ""
  local ok, module_info = xpcall(module_service.get_module_by_id, function(err)
    call_err = error_util.get_msg(err)
  end, id)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 转换数据类型
  module_info["rank"] = tonumber(module_info["rank"])
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(module_info))
end

--[[
  获取最大排序值
--]]
function _M.get_max_rank()
  -- 从数据库获取最大排序值
  local module_service = module.require("service.module")
  local call_err = ""
  local ok, max_rank = xpcall(module_service.get_max_rank, function(err)
    call_err = error_util.get_msg(err)
  end)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(max_rank))
end

--[[
  创建代码
--]]
function _M.create_module()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local module_info = ngx.ctx.request:get_body_json()
  -- 创建代码
  local module_service = module.require("service.module")
  local call_err = ""
  local ok = xpcall(module_service.create_module, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, module_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  更新代码
--]]
function _M.update_module()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local module_info = ngx.ctx.request:get_body_json()
  -- 更新代码
  local module_service = module.require("service.module")
  local call_err = ""
  local ok = xpcall(module_service.update_module, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, module_info)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  删除代码
--]]
function _M.delete_module()
  -- 获取请求参数
  local user_info = ngx.ctx.user_info
  local params = ngx.ctx.request:get_body_json()
  -- 删除代码
  local module_service = module.require("service.module")
  local call_err = ""
  local ok = xpcall(module_service.delete_module, function(err)
    call_err = error_util.get_msg(err)
  end, user_info, params["ids"])
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success())
end

--[[
  获取提示代码列表
--]]
function _M.get_hint_module_list()
  -- 获取请求参数
  local type = ngx.ctx.request:get_arg("type")
  -- 查询结果
  local module_service = module.require("service.module")
  local call_err = ""
  local ok, res = xpcall(module_service.get_module_list_by_type, function(err)
    call_err = error_util.get_msg(err)
  end, type)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 返回结果
  ngx.ctx.response:writeln(res_util.success(res))
end

--[[
  获取提示代码函数列表
--]]
function _M.get_hint_func_list()
  -- 获取请求参数
  local code = ngx.ctx.request:get_arg("code")
  -- 查询结果
  local module_service = module.require("service.module")
  local call_err = ""
  local ok, res = xpcall(module_service.get_module_by_code, function(err)
    call_err = error_util.get_msg(err)
  end, code)
  if not ok then
    ngx.ctx.response:writeln(res_util.failure(call_err))
    return
  end
  -- 加载模块
  local module
  if _.isEmpty(res) then
    -- 从本地项目加载模块
    local ok, mod = pcall(require, "modules." .. code)
    if ok then
      module = mod
    end
  else
    -- 加载模块代码
    module = file_util.load_lua_str(res["content"])
  end
  if not module then
    ngx.ctx.response:writeln(res_util.failure("加载[" .. code .. "]模块代码失败！"))
    return
  end
  -- 列出模块函数列表
  local func_list = {}
  for method_name, method in pairs(module) do
    if type(method) == "function" then
      table.insert(func_list, { code = method_name, name = method_name })
    end
  end
  ngx.ctx.response:writeln(res_util.success(func_list))
end

return _M
