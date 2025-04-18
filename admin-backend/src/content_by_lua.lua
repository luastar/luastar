--[[
    在每次请求时处理
--]]
local ngx = ngx

local _M = {}

--[[
-- 初始化上下文
--]]
function _M.init_ctx()
    -- 初始化输入输出
    local http_request = require "core.http_request"
    local http_response = require "core.http_response"
    ngx.ctx.request = http_request:new()
    ngx.ctx.response = http_response:new()
    -- 初始化 trace_id
    local trace_id = ngx.ctx.request:get_header_single("trace_id")
    local str_util = require "utils.str_util"
    ngx.ctx.trace_id = _.ifEmpty(trace_id, str_util.random_str(12))
    -- 初始化语言
    local lang = ngx.ctx.request:get_header_single("lang")
    ngx.ctx.lang = _.ifEmpty(lang, "zh_CN")
end

function _M.content()
    -- 初始化上下文
    _M.init_ctx()
    -- 获取路由配置
    local route = ls_context.get_route()
    -- 匹配路由信息
    local route_info = route:match_route(ngx.var.uri, ngx.var.request_method)
    if not route_info then
        logger.error("请求[", ngx.var.uri, "]匹配不到路由！")
        ngx.status = 404
        return ngx.exit(404)
    end
    -- 拦截器信息
    local interceptor_info = route:match_interceptor(ngx.var.uri, ngx.var.request_method)
    -- 执行处理模块
    _M.execute_ctrl(route_info, interceptor_info)
    -- 输出内容
    ngx.ctx.response:finish()
end

--[[
-- 执行处理类
--]]
function _M.execute_ctrl(route_info, interceptor_info)
    -- 执行拦截前方法
    local ok = _M.execute_before(interceptor_info)
    if not ok then
        return
    end
    -- 执行处理方法
    local call_ok, err_info = false, nil
    local require_ok, moudle = pcall(require, route_info["module"])
    if require_ok then
        local moudle_func = moudle[route_info["func"]]
        if moudle_func and _.isFunction(moudle_func) then
            call_ok, err_info = pcall(moudle_func, ngx.ctx.request, ngx.ctx.response, route_info["params"])
        else
            call_ok = false
            err_info = table.concat({ "加载路由处理器模块[", moudle, "]，函数[", moudle_func "]失败！" })
        end
    else
        call_ok = false
        err_info = table.concat({ "加载路由处理器模块[", moudle, "]失败！" })
    end
    if not call_ok then
        logger.error("路由处理器执行失败：", err_info)
    end
    -- 执行拦截后方法
    _M.execute_after(interceptor_info, call_ok, err_info)
end

--[[
-- 拦截器执行前处理
--]]
function _M.execute_before(interceptor_info)
    if _.size(interceptor_info) == 0 then
        return true
    end
    for key, value in pairs(interceptor_info) do
        local require_ok, interceptor = pcall(require, value)
        if require_ok then
            local before_handle_method = interceptor["beforeHandle"]
            if before_handle_method and _.isFunction(before_handle_method) then
                local call_ok, rs_ok = pcall(before_handle_method)
                if call_ok then
                    logger.info("调用拦截器[", value, "]方法[beforeHandle]成功，返回结果为：", rs_ok)
                    -- 只要返回失败，就返回
                    if not rs_ok then
                        return false
                    end
                else
                    logger.error("调用拦截器[", value, "]方法[beforeHandle]失败：", rs_ok)
                end
            else
                logger.error("拦截器[", value, "][beforeHandle]方法不存在！")
            end
        else
            logger.error("加载拦截器[", value, "]失败: ", interceptor)
        end
    end
    return true
end

--[[
-- 拦截器执行后处理
--]]
function _M.execute_after(interceptor_info, ctrl_call_ok, err_info)
    if _.size(interceptor_info) == 0 then
        return
    end
    for key, value in pairs(interceptor_info) do
        local require_ok, interceptor = pcall(require, value)
        if require_ok then
            local after_handle_method = interceptor["afterHandle"]
            if after_handle_method and _.isFunction(after_handle_method) then
                local call_ok, res = pcall(after_handle_method, ctrl_call_ok, err_info)
                if not call_ok then
                    logger.error("调用拦截器[", value, "]方法[afterHandle]失败：", res)
                end
            else
                logger.error("拦截器[", value, "][afterHandle]方法不存在！")
            end
        else
            logger.error("加载拦截器[", value, "]失败: ", interceptor)
        end
    end
end

-- 执行
do
    _M.content()
end
