--[[
拦截器模块
--]]
local ngx = require "ngx"
local str_util = require "utils.str_util"

local _M = {}

--[===[
interceptors = {
    {
        routes = {
            {
                path = "/api/*", -- 请求路径，模式匹配使用 Lua 的模式匹配规则
                method = "*", -- 请求方法，多个方法用逗号分隔，*表示所有方法
                mode = "v"  -- 匹配模式 p(precise:精确匹配) | v(vague:模糊匹配)
            }
        },
        routes_exclude = {
            {
                path = "/api/active",
                method = "*",
                mode = "p"
            }
        }
        mid = "xxx",  -- 模块id
        params = { p1="p1", p2="p2" } -- 拦截器参数，可选
    }
}
--]===]
function _M:match_interceptor(path, method)
  if _.isEmpty(path) or _.isEmpty(method) then
    logger.error("匹配拦截器失败：请求路径或方法为空！")
    return nil
  end
  -- 从字典中获取拦截器信息
  local dict = ngx.shared.dict_ls_interceptors;
  local interceptors_str = dict:get("interceptors");
  if not interceptors_str then
    logger.error("匹配拦截器失败：拦截器信息为空！")
    return nil
  end
  local interceptors_table = cjson.decode(interceptors_str);
  -- 拦截器匹配
  local matched_ary = {}
  for k1, interceptor in ipairs(interceptors_table) do
    if _.isArray(interceptor["routes"]) then
      -- 是否拦截
      local is_interceptor = false
      -- 请求方式 和 uri 是否匹配
      for k2, route in ipairs(interceptor["routes"]) do
        if str_util.path_and_method_is_macth(path, method, route["path"], route["method"], route["mode"]) then
          is_interceptor = true
          if _.isArray(interceptor["routes_exclude"]) then
            -- 是否被排除
            for k3, route_exclude in ipairs(interceptor["routes_exclude"]) do
              if str_util.path_and_method_is_macth(path, method, route_exclude["path"], route_exclude["method"], route_exclude["mode"]) then
                is_interceptor = false
                break
              end
            end
          end
          break
        end
      end
      -- 添加到拦截器列表
      if is_interceptor then
        table.insert(matched_ary, {
          code = interceptor["code"],
          mid = interceptor["mid"],
          mfunc_before = interceptor["mfunc_before"],
          mfunc_after = interceptor["mfunc_after"],
          params = interceptor["params"],
        })
      end
    end
  end
  return matched_ary
end

return _M
