--[[
  访问控制阶段执行
--]]
local ngx = require "ngx"
local request = require "core.request"
local response = require "core.response"
local stats = require "core.stats"
local res_util = require "utils.res_util"
local str_util = require "utils.str_util"

--[[
  初始化上下文
--]]
local function init_ctx()
  -- 记录开始请求时间（毫秒级）
  ngx.ctx.start_time = ngx.now() * 1000
  -- 初始化输入输出
  ngx.ctx.request = request:new()
  ngx.ctx.response = response:new()
  -- 初始化 trace_id
  local trace_id = ngx.ctx.request:get_header_single("trace_id")
  ngx.ctx.trace_id = _.ifEmpty(trace_id, str_util.random_str(12))
  -- 初始化语言
  local lang = ngx.ctx.request:get_header_single("lang")
  ngx.ctx.lang = _.ifEmpty(lang, "zh_CN")
  -- 初始化统计
  stats.init()
end

--[[
  中断回调，确保 ngx.exit() 后也能记录统计数据
--]]
local function abort_callback()
  stats.record_access()
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
  -- 注册中断回调
  local ok, err = ngx.on_abort(abort_callback)
  if not ok then
    local msg = "failed to register the on_abort callback: " .. err
    logger.error(msg)
    ngx.say(msg)
    ngx.exit(500)
  end
  -- 匹配路由
  local route = require "core.route"
  local matched_route = route:match_route(ngx.var.uri, ngx.var.request_method)
  if not matched_route then
    local msg = table.concat({
      "请求[path = ", ngx.var.uri, ", method = ", ngx.var.request_method, "]匹配不到路由！",
    }, "")
    logger.error(msg)
    ngx.say(msg)
    ngx.ctx.exit_status = 404 -- on_abort 回调函数通过 ngx.status 获取不到 ngx.exit(status)中的状态码
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
