--[===[
  获取统计数据
--]===]
local sql_util = require "utils.sql_util"
local error_util = require "utils.error_util"

local _M = {}

--[[
 获取统计数据
--]]
function _M.get_data(params)
  -- 参数校验
  if _.isEmpty(params["type"]) then
    error_util.throw("参数[type]不能为空！")
  end
  if _.isEmpty(params["start_time"]) then
    error_util.throw("参数[start_time]不能为空！")
  end
  if _.isEmpty(params["end_time"]) then
    error_util.throw("参数[end_time]不能为空！")
  end
  -- mysql 服务
  local mysql_service = ls_cache.get_bean("mysql_service")
  -- 查询语句
  local sql_query = sql_util.fmt_sql(
    [[
      select * from ls_stats
      where type = #{type}
      and timestamp >= #{start_time}
      and timestamp <= #{end_time}
      order by timestamp;
    ]],
    {
      type = params["type"],
      start_time = params["start_time"],
      end_time = params["end_time"]
    }
  )
  local res, err, errcode, sqlstate = mysql_service:query(sql_query)
  if not res then
    logger.error("查询统计信息失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
    error_util.throw("查询统计信息失败 : " .. err)
  end
  return res
end

return _M
