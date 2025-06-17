local ngx = require "ngx"
local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait
local stats = require "core.stats"
local sql_util = require "utils.sql_util"

--[===[
数据同步模块
--]===]

local _M = {}

--[[
同步配置信息
--]]
function _M.sync_config()
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql = [[ select * from ls_config where state = 'enable'; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql)
  if not res then
    logger.error("获取配置信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    return
  end
  local dict = ngx.shared.dict_ls_configs
  if _.isEmpty(res) then
    dict:flush_all()
    return
  end
  for k, v in pairs(res) do
    local config_info = {
      vtype = v["vtype"],
      vcontent = v["vcontent"],
    }
    local ok, err = dict:safe_set(v["code"], cjson.encode(config_info))
    if not ok then
      logger.error("保存配置信息到字典失败 : id = ", v.id, ", err = ", err)
    end
  end
end

--[[
同步路由信息
--]]
function _M.sync_route()
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql = [[ select * from ls_route where state = 'enable' order by rank; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql)
  if not res then
    logger.error("获取路由信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    return
  end
  local dict = ngx.shared.dict_ls_routes
  if _.isEmpty(res) then
    dict:flush_all()
    return
  end
  local routes_table = {}
  for k, v in pairs(res) do
    table.insert(routes_table, {
      type = v["type"] or "unknown",
      code = v["code"],
      path = v["path"],
      method = v["method"],
      mode = v["mode"],
      mcode = v["mcode"],
      mfunc = v["mfunc"],
      params = v["params"]
    })
  end
  local routes_str = cjson.encode(routes_table)
  local ok, err = dict:safe_set("routes", routes_str)
  if not ok then
    logger.error("保存路由信息到字典失败 : err = ", err)
  end
end

--[[
同步拦截器信息
--]]
function _M.sync_interceptor()
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql = [[ select * from ls_interceptor where state = 'enable' order by rank; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql)
  if not res then
    logger.error("获取拦截器信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    return
  end
  local dict = ngx.shared.dict_ls_interceptors
  if _.isEmpty(res) then
    dict:flush_all()
    return
  end
  local interceptors_table = {}
  for k, v in pairs(res) do
    local routes_exclude = nil
    if not _.isEmpty(v.routes_exclude) then
      routes_exclude = cjson.decode(v.routes_exclude)
    end
    table.insert(interceptors_table, {
      code = v.code,
      routes = cjson.decode(v.routes),
      routes_exclude = routes_exclude,
      mcode = v.mcode,
      mfunc_before = v.mfunc_before,
      mfunc_after = v.mfunc_after,
      params = v.params
    })
  end
  local interceptors_str = cjson.encode(interceptors_table)
  local ok, err = dict:safe_set("interceptors", interceptors_str)
  if not ok then
    logger.error("保存拦截器信息到字典失败 : err = ", err)
  end
end

--[[
同步模块代码信息
--]]
function _M.sync_module()
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql = [[ select * from ls_module where state = 'enable'; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql)
  if not res then
    logger.error("获取模块代码信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    return
  end
  local dict = ngx.shared.dict_ls_modules
  if _.isEmpty(res) then
    dict:flush_all()
    return
  end
  for k, v in pairs(res) do
    local ok, err = dict:safe_set(v.code, v.content)
    if not ok then
      logger.error("保存模块代码信息到字典失败 : code = ", v.code, ", err = ", err)
    end
  end
end

--[[
同步统计信息
--]]
function _M.sync_stats()
  -- 数据字典
  local dict = ngx.shared[stats.KEYS.KEY_DICT_NAME]
  if not dict then
    return
  end
  -- 当前时间
  local timestamp = math.floor(ngx.time() / 60) * 60
  -- 开始时间
  local start_time = timestamp - 120
  -- 最后持久化时间
  local last_persist_time = dict:get(stats.KEYS.KEY_LAST_PERSIST_TIME)
  if last_persist_time then
    start_time = last_persist_time + 60
  end
  -- 截止时间
  local end_time = timestamp - 60
  -- 获取统计数据
  local stats_data = stats.get_stats_data(start_time, end_time)
  -- 没有要持久化的数据
  if _.isEmpty(stats_data) then
    return
  end
  -- 保存到数据库
  local mysql_service = ls_cache.get_bean("mysql_service")
  for i, v in ipairs(stats_data) do
    -- 先查询是否保存过
    local sql_query = sql_util.fmt_sql(
      [[ select * from ls_stats where type = #{type} and timestamp = #{timestamp};]],
      v
    )
    local res, err, errcode, sqlstate = mysql_service:query(sql_query)
    if _.isEmpty(res) then
      -- 再保存到数据库
      v["id"] = tostring(v["timestamp"]) .. "-" .. i
      local sql_save = sql_util.fmt_sql(
        [[
          insert into ls_stats (
            id, type, timestamp, timestamp_str,
            value01, value02, value03, value04, value05,
            create_by, create_at, update_by, update_at
          ) values (
            #{id}, #{type}, #{timestamp}, #{timestamp_str}, #{value01}, #{value02}, #{value03}, #{value04}, #{value05},
            'admin', now(), 'admin', now()
          );
        ]],
        v
      )
      local res, err, errcode, sqlstate = mysql_service:query(sql_save)
      if not res then
        logger.error("保存统计信息到数据库失败 : err = ", err)
      end
    end
  end
  -- 删除保存过的数据
  stats.delete_stats_data(start_time, end_time)
  -- 更新最后同步时间
  dict:set(stats.KEYS.KEY_LAST_PERSIST_TIME, end_time)
end

--[[
同步数据库信息到数据字典
--]]
function _M.sync_db_to_dict()
  local thread_sync_config = ngx_thread_spawn(_M.sync_config)
  local thread_sync_route = ngx_thread_spawn(_M.sync_route)
  local thread_sync_interceptor = ngx_thread_spawn(_M.sync_interceptor)
  local thread_sync_module = ngx_thread_spawn(_M.sync_module)
  ngx_thread_wait(
    thread_sync_config,
    thread_sync_route,
    thread_sync_interceptor,
    thread_sync_module
  )
end

--[[
同步数据字典信息到数据库
--]]
function _M.sync_dict_to_db()
  _M.sync_stats()
end

return _M
