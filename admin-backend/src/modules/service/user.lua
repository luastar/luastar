--[===[
    用户管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取用户信息
--]]
function _M.get_user_info(username)
  -- 参数校验
  if _.isEmpty(username) then
    error("[username]不能为空")
  end
  -- 从数据库获取用户信息
  local bean_factory = ls_cache.get_bean_factory();
  local mysql_service = bean_factory:get_bean("mysql_service");
  local sql_user_query = sql_util.fmt_sql(
    [[ select * from ls_user where username = #{username} and state = 'enable' limit 1; ]],
    { username = username }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_user_query);
  if not res then
    logger.error("查询用户信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error("查询用户信息失败 : " .. err)
  end
  if _.isEmpty(res) then
    error("用户不存在")
  end
  return res[1]
end

--[[
 获取用户角色和权限
--]]
function _M.get_user_role_permission(uid)
  -- 参数校验
  if _.isEmpty(uid) then
    error("[uid]不能为空")
  end
  -- 从数据库获取用户角色和权限
  local bean_factory = ls_cache.get_bean_factory();
  local mysql_service = bean_factory:get_bean("mysql_service");
  local sql_role_query = sql_util.fmt_sql(
    [[
      select t1.id, t1.code
      from ls_role t1
      inner join ls_user_role t2 on t2.rid = t1.id
      where t2.uid = #{uid};
    ]],
    { uid = uid }
  )
  local sql_permission_query = sql_util.fmt_sql(
    [[
      select t1.id, t1.code
      from ls_permission t1
      inner join ls_role_permission t2 on t2.pid = t1.id
      inner join ls_user_role t3 on t3.rid = t2.rid
      where t3.uid = #{uid};
    ]],
    { uid = uid }
  )
  local thread_role_query = ngx_thread_spawn(function()
    local res, err, errcode, sqlstate = mysql_service:query(sql_role_query);
    if not res then
      logger.error("查询用户角色失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error("查询用户角色失败 : " .. err)
    end
    return res
  end);
  local thread_permission_query = ngx_thread_spawn(function()
    local res, err, errcode, sqlstate = mysql_service:query(sql_permission_query)
    if not res then
      logger.error("查询用户权限失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
      error("查询用户权限失败 : " .. err)
    end
    return res
  end);
  local ok1, res1 = ngx_thread_wait(thread_role_query);
  local ok2, res2 = ngx_thread_wait(thread_permission_query);
  if not ok1 or not ok2 then
    error("查询用户角色和权限失败")
  end
  -- 返回角色和权限编码数组
  local roles = _.mapi(res1, function(v, k)
    return v.code
  end)
  local permissions = _.mapi(res2, function(v, k)
    return v.code
  end)
  return roles, permissions
end

return _M
