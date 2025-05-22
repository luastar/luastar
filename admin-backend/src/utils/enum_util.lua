local ngx = require "ngx"

local _M = {}

-- http 请求方式
_M.HTTP_METHOD = {
  GET = ngx.HTTP_GET,
  HEAD = ngx.HTTP_HEAD,
  PUT = ngx.HTTP_PUT,
  POST = ngx.HTTP_POST,
  DELETE = ngx.HTTP_DELETE,
  OPTIONS = ngx.HTTP_OPTIONS,
  MKCOL = ngx.HTTP_MKCOL,
  COPY = ngx.HTTP_COPY,
  MOVE = ngx.HTTP_MOVE,
  PROPFIND = ngx.HTTP_PROPFIND,
  PROPPATCH = ngx.HTTP_PROPPATCH,
  LOCK = ngx.HTTP_LOCK,
  UNLOCK = ngx.HTTP_UNLOCK,
  PATCH = ngx.HTTP_PATCH,
  TRACE = ngx.HTTP_TRACE
}

-- 级别
_M.LEVEL = {
  SYSTEM = "system",
  USER = "user",
}

-- 状态
_M.STATE = {
  ENABLE = "enable",
  DISABLE = "disable",
}

-- 全部
_M.ALL = "*"

-- 路由匹配模式
_M.ROUTE_MODE = {
  PRECISE = "p",
  VAGUE = "v",
}

-- 配置值类型
_M.CONFIG_VTYPE = {
  OBJECT = "object",
  ARRAY = "array",
  STRING = "string",
  NUMBER = "number",
  BOOLEAN = "boolean",
}

return _M
