--[[
  访问控制阶段执行
--]]
local ngx = require "ngx"
local request = require "core.request"
local response = require "core.response"
local res_util = require "utils.res_util"

--[[
  初始化上下文
--]]
local function init_ctx()
  -- 初始化输入输出
  ngx.ctx.request = request:new()
  ngx.ctx.response = response:new()
  -- 初始化 trace_id
  local trace_id = ngx.ctx.request:get_header_single("trace_id")
  local str_util = require "utils.str_util"
  ngx.ctx.trace_id = _.ifEmpty(trace_id, str_util.random_str(12))
  -- 初始化语言
  local lang = ngx.ctx.request:get_header_single("lang")
  ngx.ctx.lang = _.ifEmpty(lang, "zh_CN")
end

--[[
  执行拦截器前置处理
--]]
local function handle_before(matched_interceptor)
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

-- 执行
do
  -- 初始化上下文
  init_ctx()
  -- 匹配路由
  local route = require "core.route"
  local matched_route = route:match_route(ngx.var.uri, ngx.var.request_method)
  if not matched_route then
    logger.error("请求[path = ", ngx.var.uri, ", method = ", ngx.var.request_method, "]匹配不到路由！")
    ngx.exit(404)
    return
  end
  ngx.ctx.matched_route = matched_route
  -- 匹配拦截器
  local interceptor = require "core.interceptor"
  local matched_interceptor = interceptor:match_interceptor(ngx.var.uri, ngx.var.request_method)
  ngx.ctx.matched_interceptor = matched_interceptor
  -- 执行拦截前方法
  local ok = handle_before(matched_interceptor)
  if not ok then
    -- 输出内容并退出
    ngx.ctx.response:set_content_type_json()
    ngx.ctx.response:finish()
    ngx.exit()
  end
end
