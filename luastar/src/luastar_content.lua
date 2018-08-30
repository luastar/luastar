--[[

--]]
--require('mobdebug').start("127.0.0.1")
local resty_random = require("resty.random")
local db_monitor = require("luastar.db.monitor")
local Request = require("luastar.core.request")
local Response = require("luastar.core.response")

function content()
    -- 初始化应用包路径，有缓存，只初始化一次
    luastar_context.init_pkg_path()
    -- 初始化输入输出
    ngx.ctx.request_id = resty_random.token(20)
    ngx.ctx.request = Request:new()
    ngx.ctx.response = Response:new()
    -- 获取路由相关配置
    local route = luastar_context.getRoute()
    -- 限制策略
    local limit_config = route:getLimit()
    local is_limit, limit_msg = limit(limit_config)
    if is_limit then
        ngx.log(ngx.ERR, "请求[", ngx.var.uri, "]被限制：", limit_msg)
        -- ngx.status = 403
        ngx.print(limit_msg)
        return ngx.exit(200)
    end
    -- 路由处理器
    local ctrl_config = route:getRoute(ngx.var.request_method, ngx.var.uri)
    if not ctrl_config then
        ngx.log(ngx.ERR, "请求[", ngx.var.uri, "]找不到处理类！")
        ngx.status = 404
        return ngx.exit(404)
    end
    -- 路由拦截器
    local interceptorAry = route:getInterceptor(ngx.var.request_method, ngx.var.uri)
    -- 执行处理方法
    execute_ctrl(ctrl_config, interceptorAry)
    -- 监控数据库连接
    db_monitor.check("redis_connect", "mysql_connect")
    -- 输出内容
    ngx.ctx.response:finish()
end

function limit(limit_config)
    if _.isEmpty(limit_config) then
        return false, nil
    end
    local is_limit, limit_msg = false, nil
    local require_ok, limit = pcall(require, limit_config["class"])
    if require_ok then
        local limit_method = limit[limit_config["method"]]
        if limit_method and _.isFunction(limit_method) then
            local call_ok, call_res_1, call_res_2 = pcall(limit_method, ngx.ctx.request)
            if call_ok then
                is_limit, limit_msg = call_res_1, call_res_2
            else
                ngx.log(ngx.ERR, "调用limit[", limit_config["class"], "][", limit_config["method"], "]失败：", call_res_1)
            end
        end
    else
        ngx.log(ngx.ERR, "加载limit[", limit_config["class"], "]失败!")
    end
    return is_limit, limit_msg
end

--[[
-- 执行处理类
--]]
function execute_ctrl(ctrl_config, interceptorAry)
    -- 执行拦截前方法
    local interceptor_ok, interceptor_msg, interceptor_code = execute_before(interceptorAry)
    if not interceptor_ok then
        ngx.log(ngx.INFO, "拦截处理类成功！")
        if interceptor_msg then
            ngx.ctx.response:writeln(interceptor_msg)
        end
        if interceptor_code then
            ngx.status = interceptor_code
        end
        return
    end
    -- 执行处理类方法
    local call_ok, err_info = false, nil
    local require_ok, ctrl = pcall(require, ctrl_config["class"])
    if require_ok then
        local ctrl_method = ctrl[ctrl_config["method"]]
        if ctrl_method and _.isFunction(ctrl_method) then
            call_ok, err_info = pcall(ctrl_method, ngx.ctx.request, ngx.ctx.response, ctrl_config["param"])
        else
            call_ok = false
            err_info = table.concat({ "找不到处理类方法：", ctrl_config["method"] }, "")
        end
    else
        call_ok = false
        err_info = table.concat({ "加载[", ngx.var.uri, "]处理类[", ctrl_config["class"], "]失败！" }, "")
    end
    if not call_ok then
        ngx.log(ngx.ERR, "ctrl执行失败：", err_info)
    end
    -- 执行拦截后方法
    execute_after(interceptorAry, call_ok, err_info)
end

--[[
-- 拦截器执行前处理
--]]
function execute_before(interceptorAry)
    if _.size(interceptorAry) == 0 then
        return true
    end
    for key, value in pairs(interceptorAry) do
        local require_ok, interceptor = pcall(require, value)
        if require_ok then
            local before_handle_method = interceptor["beforeHandle"]
            if before_handle_method and _.isFunction(before_handle_method) then
                local call_ok, rs_ok, rs_msg, rs_code = pcall(before_handle_method)
                if call_ok then
                    -- 只要返回失败，就返回
                    if not rs_ok then
                        return false, rs_msg, rs_code
                    end
                else
                    ngx.log(ngx.ERR, "调用拦截器[", value, "]方法[beforeHandle]失败：", rs_ok)
                end
            else
                ngx.log(ngx.ERR, "拦截器[", value, "][beforeHandle]方法不存在")
            end
        else
            ngx.log(ngx.ERR, "加载拦截器[", value, "]失败: ", interceptor)
        end
    end
    return true
end

--[[
-- 拦截器执行后处理
--]]
function execute_after(interceptorAry, ctrl_call_ok, err_info)
    if _.size(interceptorAry) == 0 then
        return
    end
    for key, value in pairs(interceptorAry) do
        local require_ok, interceptor = pcall(require, value)
        if require_ok then
            local after_handle_method = interceptor["afterHandle"]
            if after_handle_method and _.isFunction(after_handle_method) then
                local call_ok, res = pcall(after_handle_method, ctrl_call_ok, err_info)
                if not call_ok then
                    ngx.log(ngx.ERR, "调用拦截器[", value, "]方法[afterHandle]失败：", res)
                end
            else
                ngx.log(ngx.ERR, "拦截器[", value, "][afterHandle]方法不存在")
            end
        else
            ngx.log(ngx.ERR, "加载拦截器[", value, "]失败: ", interceptor)
        end
    end
end

-- 执行
do
    content()
end

--require('mobdebug').done()