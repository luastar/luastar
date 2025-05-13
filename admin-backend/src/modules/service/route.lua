--[===[
    路由管理服务
--]===]
local ngx = require "ngx"
local sql_util = require "utils.sql_util"

local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

local _M = {}

--[[
 获取路由数量及列表
--]]
function _M.get_route_count_and_list(params)
    -- 参数默认值
    if _.isEmpty(params["level"]) then
        params["level"] = nil
    end
    if _.isEmpty(params["type"]) then
        params["type"] = nil
    end
    if _.isEmpty(params["code"]) then
        params["code"] = nil
    end
    if _.isEmpty(params["name"]) then
        params["name"] = nil
    end
    if _.isEmpty(params["pageNum"]) then
        params["pageNum"] = 1
    end
    if _.isEmpty(params["pageSize"]) then
        params["pageSize"] = 20
    end
    -- mysql 服务
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    -- 查询条件
    local sql_query_where = {
        [[ level = #{level} ]],
        [[ and type = #{type} ]],
        [[ and code = #{code} ]],
        [[ and name like concat('%',#{name},'%') ]]
    }
    local sql_params = {
        level = params["level"],
        type = params["type"],
        code = params["code"],
        name = params["name"],
        limit = params["pageSize"],
        offset = (params["pageNum"] - 1) * params["pageSize"]
    }
    local sql_query_count = sql_util.fmt_sql_table({
        sql = [[ select count(*) as route_num from ls_route @{where} ]],
        where = sql_query_where
    }, sql_params)
    local sql_query_list = sql_util.fmt_sql_table({
        sql = [[ select * from ls_route @{where} order by rank @{limit} ]],
        where = sql_query_where,
        limit = { limit = "${limit}", offset = "${offset}" }
    }, sql_params)
    local thread_query_count = ngx_thread_spawn(function()
        local res, err, errcode, sqlstate = mysql_service:query(sql_query_count);
        if not res then
            logger.error("查询路由数量失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
            error("查询路由数量失败 : " .. err)
        end
        return res
    end);
    local thread_query_list = ngx_thread_spawn(function()
        local res, err, errcode, sqlstate = mysql_service:query(sql_query_list);
        if not res then
            logger.error("查询路由列表失败: err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate)
            error("查询路由列表失败 : " .. err)
        end
        return res
    end);
    local ok1, res1 = ngx_thread_wait(thread_query_count);
    local ok2, res2 = ngx_thread_wait(thread_query_list);
    if not ok1 or not ok2 then
        error("查询路由列表失败")
    end
    return tonumber(res1[1]["route_num"]), res2
end

return _M
