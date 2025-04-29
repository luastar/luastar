local ngx = require "ngx"
local ngx_thread_spawn = ngx.thread.spawn
local ngx_thread_wait = ngx.thread.wait

--[===[
数据同步模块
--]===]

local _M = {}

--[[
同步路由信息
--]]
function _M.sync_route()
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    local sql = [[ select * from ls_route where state = 'enable' order by rank; ]];
    local res, err, errcode, sqlstate = mysql_service:query(sql);
    if not res then
        logger.error("获取路由信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate);
        return
    end
    -- logger.info("获取路由信息成功 : ", cjson.encode(res));
    local routes_table = {}
    for k, v in pairs(res) do
        table.insert(routes_table, {
            code = v.code,
            path = v.path,
            method = v.method,
            mode = v.mode,
            mcode = v.mcode,
            mfunc = v.mfunc,
            params = v.params
        })
    end
    local dict = ngx.shared.dict_ls_routes;
    local routes_str = cjson.encode(routes_table);
    local ok, err = dict:safe_set("routes", routes_str);
    if ok then
        -- logger.info("保存路由信息到字典成功 : ", routes_str);
    else
        logger.error("保存路由信息到字典失败 : err = ", err);
    end
end

--[[
同步拦截器信息
--]]
function _M.sync_interceptor()
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    local sql = [[ select * from ls_interceptor where state = 'enable' order by rank; ]];
    local res, err, errcode, sqlstate = mysql_service:query(sql);
    if not res then
        logger.error("获取拦截器信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate);
        return
    end
    local interceptors_table = {}
    for k, v in pairs(res) do
        local routes_exclude = nil;
        if not _.isEmpty(v.routes_exclude) then
            routes_exclude = cjson.decode(v.routes_exclude);
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
    local dict = ngx.shared.dict_ls_interceptors;
    local interceptors_str = cjson.encode(interceptors_table);
    local ok, err = dict:safe_set("interceptors", interceptors_str);
    if not ok then
        logger.error("保存拦截器信息到字典失败 : err = ", err);
    end
end

--[[
同步模块代码信息
--]]
function _M.sync_module()
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    local sql = [[ select * from ls_module where state = 'enable'; ]];
    local res, err, errcode, sqlstate = mysql_service:query(sql);
    if not res then
        logger.error("获取模块代码信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate);
        return
    end
    local dict = ngx.shared.dict_ls_modules;
    for k, v in pairs(res) do
        local ok, err = dict:safe_set(v.code, v.content);
        if not ok then
            logger.error("保存模块代码信息到字典失败 : code = ", v.code, ", err = ", err);
        end
    end
end

--[[
同步配置信息
--]]
function _M.sync_config()
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    local sql = [[ select * from ls_config where state = 'enable'; ]];
    local res, err, errcode, sqlstate = mysql_service:query(sql);
    if not res then
        logger.error("获取配置信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate);
        return
    end
    local dict = ngx.shared.dict_ls_configs;
    for k, v in pairs(res) do
        local config_info = {
            code = v.code,
            vtype = v.vtype,
            vcontent = v.vcontent,
        }
        local ok, err = dict:safe_set(v.id, cjson.encode(config_info));
        if not ok then
            logger.error("保存配置信息到字典失败 : id = ", v.id, ", err = ", err);
        end
    end
end

--[[
同步所有信息
--]]
function _M.sync()
    local thread_sync_route = ngx_thread_spawn(_M.sync_route);
    local thread_sync_interceptor = ngx_thread_spawn(_M.sync_interceptor);
    local thread_sync_module = ngx_thread_spawn(_M.sync_module);
    local thread_sync_config = ngx_thread_spawn(_M.sync_config);
    ngx_thread_wait(thread_sync_route, thread_sync_interceptor, thread_sync_module, thread_sync_config);
end

return _M
