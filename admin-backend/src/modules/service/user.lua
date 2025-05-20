--[===[
    用户管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
 获取用户信息
--]]
function _M.get_user_info_by_name(username)
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
 获取用户信息
--]]
function _M.get_user_info_by_id(id)
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
 获取用户角色
--]]
function _M.get_user_role(uid)
  -- 参数校验
  if _.isEmpty(uid) then
    error_util.throw("[uid]不能为空")
  end
  -- 从数据库获取用户角色
  local mysql_service = ls_cache.get_bean("mysql_service")
  local sql_role_query = sql_util.fmt_sql(
    [[
      select t1.id, t1.code
      from ls_role t1
      inner join ls_user_role t2 on t2.rid = t1.id
      where t2.uid = #{uid};
    ]],
    { uid = uid }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_role_query)
  if not res then
    logger.error("查询用户角色失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询用户角色失败 : " .. err)
  end
  -- 返回角色编码数组
  local roles = _.mapi(res, function(v, k)
    return v.code
  end)
  return roles
end

return _M
