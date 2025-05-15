--[===[
    配置管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"
local error_util = require "utils.error_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取配置信息
--]]
function _M.get_config_by_code(code)
  -- 参数校验
  if _.isEmpty(code) then
    error_util.throw("参数[code]不能为空！")
  end
  -- mysql 服务
  local bean_factory = ls_cache.get_bean_factory();
  local mysql_service = bean_factory:get_bean("mysql_service");
  -- 查询语句
  local sql_query = sql_util.fmt_sql([[ select * from ls_config where code = #{code} ]], { code = code })
  local res, err, errcode, sqlstate = mysql_service:query(sql_query);
  if not res then
    logger.error("查询配置信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询配置信息失败 : " .. err)
  end
  return res[1]
end

return _M
