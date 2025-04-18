local _M = {}

function _M.sync_routes()
    local bean_factory = ls_cache.get_bean_factory();
    local mysql_service = bean_factory:get_bean("mysql_service");
    local sql = [[ select * from ls_route order by rank; ]];
    local res, err, errcode, sqlstate = mysql_service:query(sql);
    if not res then
        logger.error("获取路由信息失败 : err = ", err, ", errcode = ", errcode, ", sqlstate = ", sqlstate);
        return
    end
    logger.info("获取路由信息成功 : ", cjson.encode(res));
end

return _M
