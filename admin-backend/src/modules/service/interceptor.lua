--[===[
    拦截器管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local id_util = require "utils.id_util"
local date_util = require "utils.date_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取拦截器数量及列表
--]]
function _M.get_interceptor_count_and_list(params)
  -- 参数默认值
  local keys = { "level", "code", "name" }
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
    [[ and `code` = #{code} ]],
    [[ and `name` like concat('%',#{name},'%') ]]
  }
  local sql_params = {
    level = params["level"],
    code = params["code"],
    name = params["name"],
    limit = params["pageSize"],
    offset = (params["pageNum"] - 1) * params["pageSize"]
  }
  -- 查询总数
  local thread_query_count = ngx_thread_spawn(function()
    local sql_query_count = sql_util.fmt_sql_table({
      sql = [[ select count(*) as total from ls_interceptor @{where}; ]],
      where = sql_query_where
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_count)
    if not res then
      logger.error("查询拦截器数量失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询拦截器数量失败 : " .. err)
    end
    return tonumber(res[1]["total"])
  end)
  -- 查询列表
  local thread_query_list = ngx_thread_spawn(function()
    local sql_query_list = sql_util.fmt_sql_table({
      sql = [[ select * from ls_interceptor @{where} order by `rank` desc @{limit}; ]],
      where = sql_query_where,
      limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_list)
    if not res then
      logger.error("查询拦截器列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询拦截器列表失败 : " .. err)
    end
    return res
  end)
  -- 等待查询结果
  local ok1, res1 = ngx_thread_wait(thread_query_count)
  local ok2, res2 = ngx_thread_wait(thread_query_list)
  if not ok1 or not ok2 then
    error_util.throw("查询拦截器列表失败")
  end
  return res1, res2
end

--[[
 获取拦截器信息
--]]
function _M.get_interceptor_by_id(id)
  -- 参数校验
  if _.isEmpty(id) then
    error_util.throw("参数[id]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_interceptor where `id` = #{id}; ]],
    { id = id }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询拦截器信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询拦截器信息失败 : " .. err)
  end
  return res[1]
end

--[[
 获取最大排序
--]]
function _M.get_max_rank()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = [[ select max(`rank`) as max_rank from ls_interceptor; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询拦截器信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询拦截器信息失败 : " .. err)
  end
  -- 返回结果
  return tonumber(res[1]["max_rank"]) or 0
end

--[[
 创建拦截器信息
--]]
function _M.create_interceptor(user_info, interceptor_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(interceptor_info) then
    error_util.throw("参数[interceptor_info]不能为空！")
  end
  if _.isEmpty(interceptor_info["level"]) then
    interceptor_info["level"] = enum_util.LEVEL.USER
  end
  if _.isEmpty(interceptor_info["code"]) then
    error_util.throw("参数[interceptor_info.code]不能为空！")
  end
  if _.isEmpty(interceptor_info["name"]) then
    error_util.throw("参数[interceptor_info.name]不能为空！")
  end
  if _.isEmpty(interceptor_info["routes"]) then
    error_util.throw("参数[interceptor_info.routes]不能为空！")
  end
  if _.isEmpty(interceptor_info["mcode"]) then
    error_util.throw("参数[interceptor_info.mcode]不能为空！")
  end
  if _.isEmpty(interceptor_info["mfunc_before"]) then
    error_util.throw("参数[interceptor_info.mfunc_before]不能为空！")
  end
  if _.isEmpty(interceptor_info["mfunc_after"]) then
    error_util.throw("参数[interceptor_info.mfunc_after]不能为空！")
  end
  if _.isEmpty(interceptor_info["state"]) then
    interceptor_info["state"] = enum_util.STATE.ENABLE
  end
  if _.isEmpty(interceptor_info["rank"]) then
    interceptor_info["rank"] = 0
  end
  -- 设置默认值
  interceptor_info["id"] = id_util.new_id()
  interceptor_info["create_by"] = user_info["username"]
  interceptor_info["create_at"] = date_util.get_time()
  interceptor_info["update_by"] = user_info["username"]
  interceptor_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      insert into ls_interceptor(
        `id`, `level`, `code`, `name`, `routes`, `routes_exclude`,
        `mcode`, `mfunc_before`, `mfunc_after`, `params`, `state`, `rank`,
        `create_by`, `create_at`, `update_by`, `update_at`
      ) values (
        #{id}, #{level}, #{code}, #{name}, #{routes}, #{routes_exclude},
        #{mcode}, #{mfunc_before}, #{mfunc_after}, #{params}, #{state}, #{rank},
        #{create_by}, #{create_at}, #{update_by}, #{update_at}
      );
    ]],
    interceptor_info
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("创建拦截器信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("创建拦截器信息失败 : " .. err)
  end
  return res
end

--[[
 修改拦截器信息
--]]
function _M.update_interceptor(user_info, interceptor_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(interceptor_info) then
    error_util.throw("参数[interceptor_info]不能为空！")
  end
  if _.isEmpty(interceptor_info["id"]) then
    error_util.throw("参数[interceptor_info.id]不能为空！")
  end
  if _.isEmpty(interceptor_info["level"]) then
    interceptor_info["level"] = "user"
  end
  if interceptor_info["level"] == "system" then
    -- error_util.throw("系统级拦截器不能修改！")
  end
  if _.isEmpty(interceptor_info["code"]) then
    error_util.throw("参数[interceptor_info.code]不能为空！")
  end
  if _.isEmpty(interceptor_info["name"]) then
    error_util.throw("参数[interceptor_info.name]不能为空！")
  end
  if _.isEmpty(interceptor_info["routes"]) then
    error_util.throw("参数[interceptor_info.routes]不能为空！")
  end
  if _.isEmpty(interceptor_info["mcode"]) then
    error_util.throw("参数[interceptor_info.mcode]不能为空！")
  end
  if _.isEmpty(interceptor_info["mfunc_before"]) then
    error_util.throw("参数[interceptor_info.mfunc_before]不能为空！")
  end
  if _.isEmpty(interceptor_info["mfunc_after"]) then
    error_util.throw("参数[interceptor_info.mfunc_after]不能为空！")
  end
  if _.isEmpty(interceptor_info["state"]) then
    interceptor_info["state"] = "enable"
  end
  if _.isEmpty(interceptor_info["rank"]) then
    interceptor_info["rank"] = 0
  end
  -- 设置默认值
  interceptor_info["update_by"] = user_info["username"]
  interceptor_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table({
    sql = [[ update ls_interceptor @{set} @{where} ; ]],
    set = {
      [[ `level` = #{level} ]],
      [[ `code` = #{code} ]],
      [[ `name` = #{name} ]],
      [[ `routes` = #{routes} ]],
      [[ `routes_exclude` = #{routes_exclude} ]],
      [[ `mcode` = #{mcode} ]],
      [[ `mfunc_before` = #{mfunc_before} ]],
      [[ `mfunc_after` = #{mfunc_after} ]],
      [[ `params` = #{params} ]],
      [[ `state` = #{state} ]],
      [[ `rank` = #{rank} ]],
      [[ `update_by` = #{update_by} ]],
      [[ `update_at` = #{update_at} ]]
    },
    where = { [[ `id` = #{id} ]] }
  }, interceptor_info)
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("修改拦截器信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("修改拦截器信息失败 : " .. err)
  end
  return res
end

--[[
 删除拦截器
--]]
function _M.delete_interceptor(user_info, ids)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(ids) then
    error_util.throw("参数[ids]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local ids_table = {}
  for i, v in ipairs(ids) do
    table.insert(ids_table, ngx.quote_sql_str(v))
  end
  local sql_query = sql_util.fmt_sql(
    [[ delete from ls_interceptor where `id` in (${ids}) and `level` = 'user'; ]],
    { ids = table.concat(ids_table, ",") }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("删除拦截器信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("删除拦截器信息失败 : " .. err)
  end
  return res
end

return _M
