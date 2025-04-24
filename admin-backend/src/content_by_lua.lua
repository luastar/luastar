--[[
    在每次请求时处理
--]]
local ngx = require "ngx"
local res_util = require "utils.res_util"

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
    -- 匹配路由
    local route = require "core.route"
    local matched_route = route:match_route(ngx.var.uri, ngx.var.request_method)
    if not matched_route then
        logger.error("请求[path = ", ngx.var.uri, ", method = ", ngx.var.request_method, "]匹配不到路由！")
        ngx.exit(404)
        return
    end
    -- 匹配拦截器
    local interceptor = require "core.interceptor"
    local matched_interceptor = interceptor:match_interceptor(ngx.var.uri, ngx.var.request_method)
    -- 执行拦截前方法
    local ok = _M.handle_before(matched_interceptor)
    if ok then
        -- 执行处理方法
        _M.handle(matched_route)
        -- 执行拦截后方法
        _M.handle_after(matched_interceptor)
    end
    -- 输出内容
    ngx.ctx.response:set_content_type_json()
    ngx.ctx.response:finish()
end

--[[
-- 拦截器执行前处理
--]]
function _M.handle_before(matched_interceptor)
    if _.size(matched_interceptor) == 0 then
        return true
    end
    local module = require "core.module"
    for i, v in ipairs(matched_interceptor) do
        local execute_ok, execute_res = module.execute(v["mcode"], v["mfunc_before"], v["params"])
        -- 调用失败
        if not execute_ok then
            logger.error("执行拦截器前置方法失败！code = ", v["code"], ", err = ", execute_res)
            ngx.status = 500
            ngx.ctx.response:writeln(res_util.error(execute_res))
            return false
        end
        -- 调用返回失败
        if not execute_res then
            return false
        end
    end
    return true
end

--[[
-- 执行路由控制器
--]]
function _M.handle(matched_route)
    local module = require "core.module"
    local ok, err = module.execute(matched_route["mcode"], matched_route["mfunc"], matched_route["params"])
    if not ok then
        logger.error("执行路由控制器失败：code = ", matched_route["code"], ", err = ", err)
        ngx.ctx.response:writeln(res_util.error(err))
        ngx.status = 500
    end
end

--[[
-- 执行拦截器后处理
--]]
function _M.handle_after(matched_interceptor)
    if _.size(matched_interceptor) == 0 then
        return
    end
    local module = require "core.module"
    for i, v in ipairs(matched_interceptor) do
        local ok, err = module.execute(v["mcode"], v["mfunc_after"], v["params"])
        if not ok then
            logger.error("执行拦截器后置方法失败：code = ", v["code"], ", err = ", err)
            ngx.ctx.response:writeln(res_util.error(err))
            ngx.status = 500
            return
        end
    end
end

-- 执行
do
    _M.content()
end
