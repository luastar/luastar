--[===[
    配置管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local id_util = require "utils.id_util"
local error_util = require "utils.error_util"
local date_util = require "utils.date_util"
local enum_util = require "utils.enum_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取配置列表
--]]
function _M.get_config_count_and_list(params)
  -- 参数默认值
  local keys = { "level", "type", "code", "name", "state" }
  for i, k in ipairs(keys) do
    if _.isEmpty(params[k]) then
      params[k] = nil
    end
  end
  if _.isEmpty(params["pageNo"]) then
    params["pageNo"] = 1
  end
  if _.isEmpty(params["pageSize"]) then
    params["pageSize"] = 10
  end
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询条件
  local sql_query_where = {
    [[ `level` = #{level} ]],
    [[ and `type` = #{type} ]],
    [[ and `code` like concat('%',#{code},'%') ]],
    [[ and `name` like concat('%',#{name},'%') ]],
    [[ and `state` = #{state} ]]
  }
  local sql_params = {
    level = params["level"],
    type = params["type"],
    code = params["code"],
    name = params["name"],
    state = params["state"],
    limit = params["pageSize"],
    offset = (params["pageNo"] - 1) * params["pageSize"]
  }
  -- 查询总数
  local thread_query_count = ngx_thread_spawn(function()
    local sql_count = sql_util.fmt_sql_table({
      sql = [[ select count(*) as total from ls_config @{where}; ]],
      where = sql_query_where
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_count)
    if not res then
      logger.error("查询配置总数失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询配置总数失败 : " .. err)
    end
    return tonumber(res[1]["total"])
  end)
  -- 查询列表
  local thread_query_list = ngx_thread_spawn(function()
    local sql_query = sql_util.fmt_sql_table({
      sql = [[ select * from ls_config @{where} order by `rank` desc @{limit}; ]],
      where = sql_query_where,
      limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query)
    if not res then
      logger.error("查询配置列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询配置列表失败 : " .. err)
    end
    return res
  end)
  -- 等待查询结果
  local ok1, res1 = ngx_thread_wait(thread_query_count)
  local ok2, res2 = ngx_thread_wait(thread_query_list)
  if not ok1 or not ok2 then
    error_util.throw("查询配置列表失败")
  end
  return res1, res2
end

--[[
 获取配置信息
--]]
function _M.get_config_by_id(id)
  -- 参数校验
  if _.isEmpty(id) then
    error_util.throw("参数[id]不能为空！")
  end
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_config where `id` = #{id}; ]],
    { id = id }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询配置信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询配置信息失败 : " .. err)
  end
  return res[1]
end

--[[
 根据编码获取配置信息
--]]
function _M.get_config_by_code(code)
  -- 参数校验
  if _.isEmpty(code) then
    error_util.throw("参数[code]不能为空！")
  end
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_config where `code` = #{code}; ]],
    { code = code }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询配置信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询配置信息失败 : " .. err)
  end
  return res[1]
end

--[[
 获取最大排序值
--]]
function _M.get_max_rank()
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local sql_query = [[ select max(`rank`) as max_rank from ls_config; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询最大排序值失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询最大排序值失败 : " .. err)
  end
  return tonumber(res[1]["max_rank"]) or 0
end

--[[
 创建配置
--]]
function _M.create_config(user_info, config_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(config_info) then
    error_util.throw("参数[config_info]不能为空！")
  end
  if _.isEmpty(config_info["level"]) then
    error_util.throw("参数[config_info.level]不能为空！")
  end
  if _.isEmpty(config_info["type"]) then
    error_util.throw("参数[config_info.type]不能为空！")
  end
  if _.isEmpty(config_info["code"]) then
    error_util.throw("参数[config_info.code]不能为空！")
  end
  if _.isEmpty(config_info["name"]) then
    error_util.throw("参数[config_info.name]不能为空！")
  end
  if _.isEmpty(config_info["vtype"]) then
    error_util.throw("参数[config_info.vtype]不能为空！")
  end
  if _.isEmpty(config_info["vcontent"]) then
    error_util.throw("参数[config_info.vcontent]不能为空！")
  end
  -- todo 检查编码是否已存在
  -- 设置默认值
  config_info["id"] = id_util.new_id()
  config_info["create_by"] = user_info["username"]
  config_info["create_at"] = date_util.get_time()
  config_info["update_by"] = user_info["username"]
  config_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      insert into ls_config(
        `id`, `level`, `type`, `code`, `name`,
        `vtype`, `vcontent`, `state`, `rank`,
        `create_by`, `create_at`, `update_by`, `update_at`
      ) values (
        #{id}, #{level}, #{type}, #{code}, #{name},
        #{vtype}, #{vcontent}, #{state}, #{rank},
          #{create_by}, #{create_at}, #{update_by}, #{update_at}
      );
    ]],
    config_info
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("创建配置失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("创建配置失败 : " .. err)
  end
  return res
end

--[[
 更新配置
--]]
function _M.update_config(user_info, config_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(config_info) then
    error_util.throw("参数[config_info]不能为空！")
  end
  if _.isEmpty(config_info["id"]) then
    error_util.throw("参数[config_info.id]不能为空！")
  end
  if _.isEmpty(config_info["level"]) then
    error_util.throw("参数[config_info.level]不能为空！")
  end
  if _.isEmpty(config_info["type"]) then
    error_util.throw("参数[config_info.type]不能为空！")
  end
  if _.isEmpty(config_info["code"]) then
    error_util.throw("参数[config_info.code]不能为空！")
  end
  if _.isEmpty(config_info["name"]) then
    error_util.throw("参数[config_info.name]不能为空！")
  end
  if _.isEmpty(config_info["vtype"]) then
    error_util.throw("参数[config_info.vtype]不能为空！")
  end
  if _.isEmpty(config_info["vcontent"]) then
    error_util.throw("参数[config_info.vcontent]不能为空！")
  end
  -- todo 检查编码是否已存在

  -- 设置默认值
  config_info["update_by"] = user_info["username"]
  config_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table({
    sql = [[ update ls_config @{set} @{where}; ]],
    set = {
      [[ `level` = #{level} ]],
      [[ `type` = #{type} ]],
      [[ `code` = #{code} ]],
      [[ `name` = #{name} ]],
      [[ `vtype` = #{vtype} ]],
      [[ `vcontent` = #{vcontent} ]],
      [[ `state` = #{state} ]],
      [[ `update_by` = #{update_by} ]],
      [[ `update_at` = #{update_at} ]]
    },
    where = { [[ `id` = #{id} ]] }
  }, config_info)
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("更新配置失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("更新配置失败 : " .. err)
  end
  return res
end

--[[
 删除配置
--]]
function _M.delete_config(user_info, ids)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(ids) then
    error_util.throw("参数[ids]不能为空！")
  end
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory()
  local mysql_service = bean_factory:get_bean("mysql_service")
  -- 查询语句
  local ids_table = {}
  for i, v in ipairs(ids) do
    table.insert(ids_table, ngx.quote_sql_str(v))
  end
  local sql_query = sql_util.fmt_sql(
    [[ delete from ls_config where id in (${ids}) and level = 'user'; ]],
    { ids = table.concat(ids_table, ",") }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("删除配置失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("删除配置失败 : " .. err)
  end
  return res
end

return _M
