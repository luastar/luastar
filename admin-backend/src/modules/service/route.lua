--[===[
    路由管理服务
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
 获取路由数量及列表
--]]
function _M.get_route_count_and_list(params)
  -- 参数默认值
  local keys = { "level", "type", "code", "name", "path" }
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
    [[ and `name` like concat('%',#{name},'%') ]],
    [[ and `path` like concat('%',#{path},'%') ]]
  }
  local sql_params = {
    level = params["level"],
    type = params["type"],
    code = params["code"],
    name = params["name"],
    path = params["path"],
    limit = params["pageSize"],
    offset = (params["pageNum"] - 1) * params["pageSize"]
  }
  -- 查询总数
  local thread_query_count = ngx_thread_spawn(function()
    local sql_query_count = sql_util.fmt_sql_table({
      sql = [[ select count(*) as total from ls_route @{where}; ]],
      where = sql_query_where
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_count)
    if not res then
      logger.error("查询路由数量失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询路由数量失败 : " .. err)
    end
    return tonumber(res[1]["total"])
  end)
  -- 查询列表
  local thread_query_list = ngx_thread_spawn(function()
    local sql_query_list = sql_util.fmt_sql_table({
      sql = [[ select * from ls_route @{where} order by `rank` desc @{limit}; ]],
      where = sql_query_where,
      limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_list)
    if not res then
      logger.error("查询路由列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询路由列表失败 : " .. err)
    end
    return res
  end)
  -- 等待查询结果
  local ok1, res1 = ngx_thread_wait(thread_query_count)
  local ok2, res2 = ngx_thread_wait(thread_query_list)
  if not ok1 or not ok2 then
    error_util.throw("查询路由列表失败")
  end
  return res1, res2
end

--[[
 获取路由信息
--]]
function _M.get_route_by_id(id)
  -- 参数校验
  if _.isEmpty(id) then
    error_util.throw("参数[id]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[ select * from ls_route where `id` = #{id}; ]],
    { id = id }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询路由信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询路由信息失败 : " .. err)
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
  local sql_query = [[ select max(`rank`) as max_rank from ls_route; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询路由信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询路由信息失败 : " .. err)
  end
  -- 返回结果
  return tonumber(res[1]["max_rank"]) or 0
end

--[[
 创建路由信息
--]]
function _M.create_route(user_info, route_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(route_info) then
    error_util.throw("参数[route_info]不能为空！")
  end
  if _.isEmpty(route_info["level"]) then
    route_info["level"] = enum_util.LEVEL.USER
  end
  if _.isEmpty(route_info["code"]) then
    error_util.throw("参数[route_info.code]不能为空！")
  end
  if _.isEmpty(route_info["name"]) then
    error_util.throw("参数[route_info.name]不能为空！")
  end
  if _.isEmpty(route_info["path"]) then
    error_util.throw("参数[route_info.path]不能为空！")
  end
  if _.isEmpty(route_info["method"]) then
    route_info["method"] = enum_util.ALL
  end
  if _.isEmpty(route_info["mode"]) then
    route_info["mode"] = enum_util.ROUTE_MODE.PRECISE
  end
  if _.isEmpty(route_info["mcode"]) then
    error_util.throw("参数[route_info.mcode]不能为空！")
  end
  if _.isEmpty(route_info["mfunc"]) then
    error_util.throw("参数[route_info.mfunc]不能为空！")
  end
  if _.isEmpty(route_info["state"]) then
    route_info["state"] = enum_util.STATE.ENABLE
  end
  if _.isEmpty(route_info["rank"]) then
    route_info["rank"] = 0
  end
  -- 设置默认值
  route_info["id"] = id_util.new_id()
  route_info["create_by"] = user_info["username"]
  route_info["create_at"] = date_util.get_time()
  route_info["update_by"] = user_info["username"]
  route_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      insert into ls_route(
        `id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`,
        `mcode`, `mfunc`, `params`, `state`, `rank`,
        `create_by`, `create_at`, `update_by`, `update_at`
      ) values (
        #{id}, #{level}, #{type}, #{code}, #{name}, #{path}, #{method}, #{mode},
        #{mcode}, #{mfunc}, #{params}, #{state}, #{rank},
        #{create_by}, #{create_at}, #{update_by}, #{update_at}
      );
    ]],
    route_info
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("创建路由信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("创建路由信息失败 : " .. err)
  end
  return res
end

--[[
 修改路由信息
--]]
function _M.update_route(user_info, route_info)
  -- 参数校验
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(route_info) then
    error_util.throw("参数[route_info]不能为空！")
  end
  if _.isEmpty(route_info["id"]) then
    error_util.throw("参数[route_info.id]不能为空！")
  end
  if _.isEmpty(route_info["level"]) then
    route_info["level"] = "user"
  end
  if route_info["level"] == "system" then
    -- error_util.throw("系统级路由不能修改！")
  end
  if _.isEmpty(route_info["code"]) then
    error_util.throw("参数[route_info.code]不能为空！")
  end
  if _.isEmpty(route_info["name"]) then
    error_util.throw("参数[route_info.name]不能为空！")
  end
  if _.isEmpty(route_info["path"]) then
    error_util.throw("参数[route_info.path]不能为空！")
  end
  if _.isEmpty(route_info["method"]) then
    route_info["method"] = "*"
  end
  if _.isEmpty(route_info["mode"]) then
    route_info["mode"] = "p"
  end
  if _.isEmpty(route_info["mcode"]) then
    error_util.throw("参数[route_info.mcode]不能为空！")
  end
  if _.isEmpty(route_info["mfunc"]) then
    error_util.throw("参数[route_info.mfunc]不能为空！")
  end
  if _.isEmpty(route_info["state"]) then
    route_info["state"] = "enable"
  end
  if _.isEmpty(route_info["rank"]) then
    route_info["rank"] = 0
  end
  -- 设置默认值
  route_info["update_by"] = user_info["username"]
  route_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table({
    sql = [[ update ls_route @{set} @{where} ; ]],
    set = {
      [[ `level` = #{level} ]],
      [[ `type` = #{type} ]],
      [[ `code` = #{code} ]],
      [[ `name` = #{name} ]],
      [[ `path` = #{path} ]],
      [[ `method` = #{method} ]],
      [[ `mode` = #{mode} ]],
      [[ `mcode` = #{mcode} ]],
      [[ `mfunc` = #{mfunc} ]],
      [[ `params` = #{params} ]],
      [[ `state` = #{state} ]],
      [[ `rank` = #{rank} ]],
      [[ `update_by` = #{update_by} ]],
      [[ `update_at` = #{update_at} ]]
    },
    where = { [[ `id` = #{id} ]] }
  }, route_info)
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("修改路由信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("修改路由信息失败 : " .. err)
  end
  return res
end

--[[
 删除路由
--]]
function _M.delete_route(user_info, ids)
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
    [[ delete from ls_route where `id` in (${ids}) and `level` = 'user'; ]],
    { ids = table.concat(ids_table, ",") }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("删除路由信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("删除路由信息失败 : " .. err)
  end
  return res
end

return _M
