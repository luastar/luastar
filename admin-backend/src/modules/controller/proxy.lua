--[===[
    代理
--]===]
local ngx = require "ngx"
local str_util = require "utils.str_util"
local res_util = require "utils.res_util"
local enum_util = require "utils.enum_util"
local http_util = require "utils.http_util"

local _M = {}

function _M.proxy(params)
  -- 参数校验
  if _.isEmpty(params) then
    ngx.ctx.response:writeln(res_util.failure("参数不能为空！"))
    return
  end
  params = cjson.decode(params)
  if _.isEmpty(params["project"]) then
    ngx.ctx.response:writeln(res_util.failure("参数[project]不能为空！"))
    return
  end
  local uri = ngx.ctx.request.uri
  -- 移除前缀
  if not _.isEmpty(params["sub_prefix"]
        and str_util.start_with(uri, params["sub_prefix"])) then
    uri = string.sub(uri, #params["sub_prefix"] + 1)
  end
  -- 增加前缀
  if not _.isEmpty(params["add_prefix"]) then
    uri = table.concat({ params["add_prefix"], uri })
  end
  -- 如果不是以 / 开头，增加 /
  if not str_util.start_with(uri, "/") then
    uri = table.concat({ "/", uri })
  end
  -- 代理方式 sub（适合返回值没有大数据量的请求）、http（http转发）  或 http_sse（http 流式返回）
  local proxy_mode = params["mode"] or "sub"
  local method = string.upper(ngx.ctx.request.request_method)
  if proxy_mode == "sub" then
    -- 子请求
    ngx.ctx.proxy_project = params["project"]
    local res = ngx.location.capture(
      "/proxy" .. uri,
      {
        args = ngx.ctx.request.query_string,
        method = enum_util.HTTP_METHOD[method] or ngx.HTTP_GET,
        ctx = ngx.ctx
      }
    )
    if not res then
      ngx.ctx.response:set_status(500)
      ngx.ctx.response:writeln("代理请求失败！")
      return
    end
    -- 返回结果
    if res.header then
      for k, v in pairs(res.header) do
        ngx.ctx.response:set_header(k, v)
      end
    end
    ngx.ctx.response:set_status(res.status)
    ngx.ctx.response:writeln(res.body)
  elseif proxy_mode == "http_sse" then
    -- http sse
    local url_table = {
      "http://", ngx.var.server_addr, ":", ngx.var.server_port, "/proxy", uri,
    }
    if not _.isEmpty(ngx.ctx.request.query_string) then
      table.insert(url_table, "?")
      table.insert(url_table, ngx.ctx.request.query_string)
    end
    local headers = ngx.req.get_headers()
    -- 写入项目信息
    headers["x-proxy-project"] = params["project"]
    local res = http_util.request_sse({
      url = table.concat(url_table, ""),
      method = method,
      headers = headers,
      body = ngx.ctx.request:get_body(),
      callback = function(data)
        ngx.ctx.response:write(data)
        ngx.ctx.response:flush(true)
      end
    })
    if not res then
      ngx.ctx.response:set_status(500)
      ngx.ctx.response:writeln("代理请求失败！")
      return
    end
  else
    -- http
    local url_table = {
      "http://", ngx.var.server_addr, ":", ngx.var.server_port, "/proxy", uri,
    }
    if not _.isEmpty(ngx.ctx.request.query_string) then
      table.insert(url_table, "?")
      table.insert(url_table, ngx.ctx.request.query_string)
    end
    local headers = ngx.req.get_headers()
    -- 写入项目信息
    headers["x-proxy-project"] = params["project"]
    local res = http_util.request({
      url = table.concat(url_table, ""),
      method = method,
      headers = headers,
      body = ngx.ctx.request:get_body()
    })
    if not res then
      ngx.ctx.response:set_status(500)
      ngx.ctx.response:writeln("代理请求失败！")
      return
    end
    -- 返回结果
    if res.headers then
      for k, v in pairs(res.headers) do
        ngx.ctx.response:set_header(k, v)
      end
    end
    ngx.ctx.response:set_status(res.status)
    ngx.ctx.response:writeln(res.body)
  end
end

return _M
