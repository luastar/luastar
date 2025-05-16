--[[
路由模块
--]]
local ngx = require "ngx"
local str_util = require "utils.str_util"

local _M = {}

--[===[
routes = {
    {
        path = "/api/hello", -- 请求路径，模式匹配使用 Lua 的模式匹配规则
        method = "GET,POST", -- 请求方法，多个方法用逗号分隔，*表示所有方法
        mode = "p",  -- 匹配模式 p(precise:精确匹配) | v(vague:模糊匹配)
        mcode = "xxx",  -- 模块编码
        mfunc = "xxx",  -- 模块函数
        params = { p1="p1", p2="p2" } -- 路由参数，可选
    }
}
--]===]
function _M:match_route(path, method)
  if _.isEmpty(path) or _.isEmpty(method) then
    logger.error("匹配路由失败：请求路径或方法名为空！")
    return nil
  end
  -- 从字典中获取路由信息
  local dict = ngx.shared.dict_ls_routes
  local routes_str = dict:get("routes")
  if not routes_str then
    logger.error("匹配路由失败：路由信息为空！")
    return nil
  end
  local routes_table = cjson.decode(routes_str)
  -- 路由匹配
  for k, v in ipairs(routes_table) do
    if str_util.path_and_method_is_macth(path, method, v["path"], v["method"], v["mode"]) then
      return v
    end
  end
  logger.info("匹配路由失败：找不到匹配的路由[", path, "]")
  return nil
end

return _M
