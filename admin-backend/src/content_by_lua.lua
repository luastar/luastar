--[[
  内容生产阶段执行
--]]
local ngx = require "ngx"
local res_util = require "utils.res_util"

--[[
-- 执行路由控制器
--]]
local function handle(matched_route)
  local module = require "core.module"
  local ok, err = module.execute(matched_route["mcode"], matched_route["mfunc"], matched_route["params"])
  if not ok then
    logger.error("执行路由控制器失败：code = ", matched_route["code"], ", err = ", err)
    ngx.ctx.response:writeln(res_util.error(err))
  end
end

--[[
-- 执行拦截器后置处理
--]]
local function handle_after(matched_interceptor)
  if _.size(matched_interceptor) == 0 then
    return
  end
  local module = require "core.module"
  for i, v in ipairs(matched_interceptor) do
    local ok, err = module.execute(v["mcode"], v["mfunc_after"], v["params"])
    if not ok then
      logger.error("执行拦截器后置方法失败：code = ", v["code"], ", err = ", err)
      ngx.ctx.response:writeln(res_util.error(err))
      return
    end
  end
end

-- 执行
do
  if ngx.get_phase() ~= "content" then
    -- 非 content 阶段不执行
    return
  end
  -- 获取匹配的路由
  local matched_route = ngx.ctx.matched_route
  -- 执行处理方法
  handle(matched_route)
  -- 获取匹配的拦截器
  local matched_interceptor = ngx.ctx.matched_interceptor
  -- 执行拦截后方法
  handle_after(matched_interceptor)
  -- 输出内容
  ngx.ctx.response:finish()
end
