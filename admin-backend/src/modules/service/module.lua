--[===[
    代码管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local id_util = require "utils.id_util"
local date_util = require "utils.date_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"
local str_util = require "utils.str_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取代码数量及列表
--]]
function _M.get_module_count_and_list(params)
  -- 参数默认值
  local keys = { "level", "type", "code", "name" }
  for i, k in ipairs(keys) do
    if _.isEmpty(params[k]) then
      params[k] = nil
    end
  end
  if _.isEmpty(params["pageNum"]) then
    params["pageNum"] = 1
  end
  if _.isEmpty(params["pageSize"]) then
    params["pageSize"] = 20
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询条件
  local sql_query_where = {
    [[ `level` = #{level} ]],
    [[ and `type` = #{type} ]],
    [[ and `code` = #{code} ]],
    [[ and `name` like concat('%',#{name},'%') ]]
  }
  local sql_params = {
    level = params["level"],
    type = params["type"],
    code = params["code"],
    name = params["name"],
    limit = params["pageSize"],
    offset = (params["pageNum"] - 1) * params["pageSize"]
  }
  -- 查询总数
  local thread_query_count = ngx_thread_spawn(function()
    local sql_query_count = sql_util.fmt_sql_table({
      sql = [[ select count(*) as total from ls_module @{where}; ]],
      where = sql_query_where
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_count)
    if not res then
      logger.error("查询代码数量失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询代码数量失败 : " .. err)
    end
    return tonumber(res[1]["total"])
  end)
  -- 查询列表
  local thread_query_list = ngx_thread_spawn(function()
    local sql_query_list = sql_util.fmt_sql_table({
      sql = [[ select * from ls_module @{where} order by `rank` desc @{limit}; ]],
      where = sql_query_where,
      limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_list)
    if not res then
      logger.error("查询代码列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询代码列表失败 : " .. err)
    end
    return res
  end)
  -- 等待查询结果
  local ok1, res1 = ngx_thread_wait(thread_query_count)
  local ok2, res2 = ngx_thread_wait(thread_query_list)
  if not ok1 or not ok2 then
    error_util.throw("查询代码列表失败")
  end
  return res1, res2
end

--[[
 获取代码信息
--]]
function _M.get_module_by_id(id)
  -- 参数校验
  if _.isEmpty(id) then
    error_util.throw("参数[id]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_module where `id` = #{id}; ]],
    { id = id }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询代码信息失败 : " .. err)
  end
  res[1]["content"] = str_util.decode_base64(res[1]["content"])
  return res[1]
end

--[[
 获取代码信息
--]]
function _M.get_module_by_code(code)
  -- 参数校验
  if _.isEmpty(code) then
    error_util.throw("参数[code]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_module where `code` = #{code}; ]],
    { code = code }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询代码信息失败 : " .. err)
  end
  if _.isEmpty(res) then
    return {}
  end
  res[1]["content"] = str_util.decode_base64(res[1]["content"])
  return res[1]
end

--[[
 获取最大排序
--]]
function _M.get_max_rank()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = [[ select max(`rank`) as max_rank from ls_module; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询代码信息失败 : " .. err)
  end
  -- 返回结果
  return tonumber(res[1]["max_rank"]) or 0
end

--[[
 创建代码信息
--]]
function _M.create_module(user_info, module_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(module_info) then
    error_util.throw("参数[module_info]不能为空！")
  end
  if _.isEmpty(module_info["level"]) then
    module_info["level"] = enum_util.LEVEL.USER
  end
  if _.isEmpty(module_info["code"]) then
    error_util.throw("参数[module_info.code]不能为空！")
  end
  if _.isEmpty(module_info["name"]) then
    error_util.throw("参数[module_info.name]不能为空！")
  end
  if _.isEmpty(module_info["state"]) then
    module_info["state"] = enum_util.STATE.ENABLE
  end
  if _.isEmpty(module_info["rank"]) then
    module_info["rank"] = 0
  end
  -- 设置默认值
  module_info["id"] = id_util.new_id()
  module_info["content"] = str_util.encode_base64(module_info["content"])
  module_info["create_by"] = user_info["username"]
  module_info["create_at"] = date_util.get_time()
  module_info["update_by"] = user_info["username"]
  module_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      insert into ls_module(
        `id`, `level`, `type`, `code`, `name`, `desc`, `content`,
        `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`
      ) values (
        #{id}, #{level}, #{type}, #{code}, #{name}, #{desc}, #{content},
        #{state}, #{rank}, #{create_by}, #{create_at}, #{update_by}, #{update_at}
      );
    ]],
    module_info
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("创建代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("创建代码信息失败 : " .. err)
  end
  return res
end

--[[
 修改代码信息
--]]
function _M.update_module(user_info, module_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(module_info) then
    error_util.throw("参数[module_info]不能为空！")
  end
  if _.isEmpty(module_info["id"]) then
    error_util.throw("参数[module_info.id]不能为空！")
  end
  if _.isEmpty(module_info["level"]) then
    module_info["level"] = "user"
  end
  if module_info["level"] == "system" then
    -- error_util.throw("系统级代码不能修改！")
  end
  if _.isEmpty(module_info["code"]) then
    error_util.throw("参数[module_info.code]不能为空！")
  end
  if _.isEmpty(module_info["name"]) then
    error_util.throw("参数[module_info.name]不能为空！")
  end
  if _.isEmpty(module_info["state"]) then
    module_info["state"] = "enable"
  end
  if _.isEmpty(module_info["rank"]) then
    module_info["rank"] = 0
  end
  -- 设置默认值
  module_info["content"] = str_util.encode_base64(module_info["content"])
  module_info["update_by"] = user_info["username"]
  module_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table({
    sql = [[ update ls_module @{set} @{where} ; ]],
    set = {
      [[ `level` = #{level} ]],
      [[ `type` = #{type} ]],
      [[ `code` = #{code} ]],
      [[ `name` = #{name} ]],
      [[ `desc` = #{desc} ]],
      [[ `content` = #{content} ]],
      [[ `state` = #{state} ]],
      [[ `rank` = #{rank} ]],
      [[ `update_by` = #{update_by} ]],
      [[ `update_at` = #{update_at} ]]
    },
    where = { [[ `id` = #{id} ]] }
  }, module_info)
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("修改代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("修改代码信息失败 : " .. err)
  end
  return res
end

--[[
 删除代码
--]]
function _M.delete_module(user_info, ids)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(ids) then
    error_util.throw("参数[ids]不能为空！")
  end
  -- 查询语句
  local ids_table = {}
  for i, v in ipairs(ids) do
    table.insert(ids_table, ngx.quote_sql_str(v))
  end
  local sql_query = sql_util.fmt_sql(
    [[ delete from ls_module where `id` in (${ids}) and `level` = 'user'; ]],
    { ids = table.concat(ids_table, ",") }
  )
  local mysql_service = ls_cache.get_bean("mysql_service")
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("删除代码信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("删除代码信息失败 : " .. err)
  end
  return res
end

--[[
 根据代码类型获取代码列表
--]]
function _M.get_module_list_by_type(type)
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table(
    {
      sql = [[ select code, name from ls_module @{where} order by rank; ]],
      where = {
        [[  `type` = #{type} ]],
        [[ and `state` = #{state} ]]
      }
    },
    { type = type, state = "enable" }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询代码列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询代码列表失败 : " .. err)
  end
  return res
end

return _M
