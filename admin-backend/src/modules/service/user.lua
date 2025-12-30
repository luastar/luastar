--[===[
    用户管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local str_util = require "utils.str_util"
local id_util = require "utils.id_util"
local date_util = require "utils.date_util"
local enum_util = require "utils.enum_util"
local error_util = require "utils.error_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取用户数量及列表
--]]
function _M.get_user_count_and_list(params)
  -- 参数默认值
  local keys = { "username", "nickname", "email" }
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
    [[ `username` like concat('%',#{username},'%') ]],
    [[ and `nickname` like concat('%',#{nickname},'%') ]],
    [[ and `email` like concat('%',#{email},'%') ]],
  }
  local sql_params = {
    username = params["username"],
    nickname = params["nickname"],
    email = params["email"],
    limit = params["pageSize"],
    offset = (params["pageNum"] - 1) * params["pageSize"]
  }
  -- 查询总数
  local thread_query_count = ngx_thread_spawn(function()
    local sql_query_count = sql_util.fmt_sql_table({
      sql = [[ select count(*) as total from ls_user @{where}; ]],
      where = sql_query_where
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_count)
    if not res then
      logger.error("查询用户数量失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询用户数量失败 : " .. err)
    end
    return tonumber(res[1]["total"])
  end)
  -- 查询列表
  local thread_query_list = ngx_thread_spawn(function()
    local sql_query_list = sql_util.fmt_sql_table({
      sql = [[ select * from ls_user @{where} order by `rank` desc @{limit}; ]],
      where = sql_query_where,
      limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local res, err, errcode, sqlstate = mysql_service:query(sql_query_list)
    if not res then
      logger.error("查询用户列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error_util.throw("查询用户列表失败 : " .. err)
    end
    return res
  end)
  -- 等待查询结果
  local ok1, res1 = ngx_thread_wait(thread_query_count)
  local ok2, res2 = ngx_thread_wait(thread_query_list)
  if not ok1 or not ok2 then
    error_util.throw("查询用户列表失败")
  end
  return res1, res2
end

--[[
 获取用户信息
--]]
function _M.get_user_by_id(id)
  -- 参数校验
  if _.isEmpty(id) then
    error_util.throw("[id]不能为空")
  end
  -- 从数据库获取用户信息
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql_user_query = sql_util.fmt_sql(
    [[ select * from ls_user where id = #{id}; ]],
    { id = id }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_user_query)
  if not res then
    logger.error("查询用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询用户信息失败 : " .. err)
  end
  if _.isEmpty(res) then
    error_util.throw("用户不存在")
  end
  return res[1]
end

--[[
 获取用户信息
--]]
function _M.get_user_by_name(username)
  -- 参数校验
  if _.isEmpty(username) then
    error_util.throw("[username]不能为空")
  end
  -- 从数据库获取用户信息
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql_user_query = sql_util.fmt_sql(
    [[ select * from ls_user where username = #{username} and state = 'enable' limit 1; ]],
    { username = username }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_user_query)
  if not res then
    logger.error("查询用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询用户信息失败 : " .. err)
  end
  if _.isEmpty(res) then
    error_util.throw("用户不存在")
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
  local sql_query = [[ select max(`rank`) as max_rank from ls_user; ]]
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询用户信息失败 : " .. err)
  end
  -- 返回结果
  return tonumber(res[1]["max_rank"]) or 0
end

--[[
 创建用户信息
--]]
function _M.create_user(user_info_op, user_info)
  -- 参数校验
  if _.isEmpty(user_info_op) then
    error_util.throw("参数[user_info_op]不能为空！")
  end
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(user_info["level"]) then
    user_info["level"] = enum_util.LEVEL.USER
  end
  if _.isEmpty(user_info["username"]) then
    error_util.throw("参数[user_info.username]不能为空！")
  end
  if _.isEmpty(user_info["nickname"]) then
    error_util.throw("参数[user_info.nickname]不能为空！")
  end
  if _.isEmpty(user_info["email"]) then
    error_util.throw("参数[user_info.email]不能为空！")
  end
  if _.isEmpty(user_info["roles"]) then
    error_util.throw("参数[user_info.roles]不能为空！")
  end
  if _.isEmpty(user_info["state"]) then
    user_info["state"] = enum_util.STATE.ENABLE
  end
  if _.isEmpty(user_info["rank"]) then
    user_info["rank"] = 0
  end
  -- 设置默认值
  user_info["id"] = id_util.new_id()
  user_info["passwd"] = str_util.sha256("LuastarAdmin123456")
  user_info["create_by"] = user_info_op["username"]
  user_info["create_at"] = date_util.get_time()
  user_info["update_by"] = user_info_op["username"]
  user_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      insert into ls_user(
        `id`, `level`, `username`, `nickname`, `email`, `passwd`, `avatar`, `roles`,
        `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`
      ) values (
        #{id}, #{level}, #{username}, #{nickname}, #{email}, #{passwd}, #{avatar}, #{roles},
        #{state}, #{rank}, #{create_by}, #{create_at}, #{update_by}, #{update_at}
      );
    ]],
    user_info
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("创建用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("创建用户信息失败 : " .. err)
  end
  return res
end

--[[
 修改用户信息
--]]
function _M.update_user(user_info_op, user_info)
  -- 参数校验
  if _.isEmpty(user_info_op) then
    error_util.throw("参数[user_info_op]不能为空！")
  end
  if _.isEmpty(user_info) then
    error_util.throw("参数[user_info]不能为空！")
  end
  if _.isEmpty(user_info["id"]) then
    error_util.throw("参数[user_info.id]不能为空！")
  end
  if _.isEmpty(user_info["level"]) then
    user_info["level"] = "user"
  end
  if user_info["level"] == "system" then
    -- error_util.throw("系统级用户不能修改！")
  end
  if _.isEmpty(user_info["username"]) then
    error_util.throw("参数[user_info.username]不能为空！")
  end
  if _.isEmpty(user_info["nickname"]) then
    error_util.throw("参数[user_info.nickname]不能为空！")
  end
  if _.isEmpty(user_info["email"]) then
    error_util.throw("参数[user_info.email]不能为空！")
  end
  if _.isEmpty(user_info["roles"]) then
    error_util.throw("参数[user_info.roles]不能为空！")
  end
  if _.isEmpty(user_info["state"]) then
    user_info["state"] = "enable"
  end
  if _.isEmpty(user_info["rank"]) then
    user_info["rank"] = 0
  end
  -- 设置默认值
  user_info["update_by"] = user_info["username"]
  user_info["update_at"] = date_util.get_time()
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql_table({
    sql = [[ update ls_user @{set} @{where} ; ]],
    set = {
      [[ `level` = #{level} ]],
      [[ `username` = #{username} ]],
      [[ `nickname` = #{nickname} ]],
      [[ `email` = #{email} ]],
      [[ `avatar` = #{avatar} ]],
      [[ `roles` = #{roles} ]],
      [[ `state` = #{state} ]],
      [[ `rank` = #{rank} ]],
      [[ `update_by` = #{update_by} ]],
      [[ `update_at` = #{update_at} ]]
    },
    where = { [[ `id` = #{id} ]] }
  }, user_info)
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("修改用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("修改用户信息失败 : " .. err)
  end
  return res
end

--[[
 修改用户密码
--]]
function _M.update_passwd(user_info_op, id, passwd)
  -- 参数校验
  if _.isEmpty(user_info_op) then
    error_util.throw("参数[user_info_op]不能为空！")
  end
  if _.isEmpty(id) then
    error_util.throw("参数[id]不能为空！")
  end
  if _.isEmpty(passwd) then
    error_util.throw("参数[passwd]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      update ls_user
      set `passwd` = #{passwd},
      `update_by` = #{update_by},
      `update_at` = #{update_at}
      where `id` = #{id}
    ]],
    {
      id = id,
      passwd = str_util.sha256(passwd),
      update_by = user_info_op["username"],
      update_at = date_util.get_time()
    }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("修改用户密码失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("修改用户密码失败 : " .. err)
  end
  return res
end

--[[
 删除用户
--]]
function _M.delete_user(user_info, ids)
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
    [[ delete from ls_user where `id` in (${ids}) and `level` = 'user'; ]],
    { ids = table.concat(ids_table, ",") }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("删除用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("删除用户信息失败 : " .. err)
  end
  return res
end

return _M
