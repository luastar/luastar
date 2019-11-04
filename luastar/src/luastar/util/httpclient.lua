--[[

--]]
local _M = {}

local http = require("resty.http")

local fmt = function(p, ...)
    if select('#', ...) == 0 then
        return p
    else
        return string.format(p, ...)
    end
end

local tprintf = function(t, p, ...)
    t[#t + 1] = fmt(p, ...)
end

local append_data = function(r, k, data, extra)
    tprintf(r, "content-disposition: form-data; name=\"%s\"", k)
    if extra.filename then
        tprintf(r, "; filename=\"%s\"", extra.filename)
    end
    if extra.content_type then
        tprintf(r, "\r\ncontent-type: %s", extra.content_type)
    end
    if extra.content_transfer_encoding then
        tprintf(r, "\r\ncontent-transfer-encoding: %s", extra.content_transfer_encoding)
    end
    tprintf(r, "\r\n\r\n")
    tprintf(r, data)
    tprintf(r, "\r\n")
end

local encode = function(t, boundary)
    local r = {}
    local _t
    for k, v in pairs(t) do
        tprintf(r, "--%s\r\n", boundary)
        _t = type(v)
        if _t == "string" then
            append_data(r, k, v, {})
        elseif _t == "table" then
            assert(v.data or v.value, "invalid input")
            local extra = {
                filename = v.filename or v.name,
                content_type = v.content_type or v.mimetype or "application/octet-stream",
                content_transfer_encoding = v.content_transfer_encoding or "binary",
            }
            append_data(r, k, v.data or v.value, extra)
        else
            error(string.format("unexpected type %s", _t))
        end
    end
    tprintf(r, "--%s--\r\n", boundary)
    return table.concat(r)
end

local hasfile = function(t)
    local is_has_file = false
    for k, v in pairs(t) do
        if type(v) == "table" then
            is_has_file = true
            break
        end
    end
    return is_has_file
end

local gen_boundary = function()
    local t = { "BOUNDARY-" }
    for i = 2, 17 do t[i] = string.char(math.random(65, 90)) end
    t[18] = "-BOUNDARY"
    return table.concat(t)
end

function _M.gen_common_params(t)
    local body = {}
    for k, v in pairs(t) do
        body[#body + 1] = k .. "=" .. v
    end
    return table.concat(body, "&")
end

function _M.gen_post_params(t)
    local body, content_type
    if hasfile(t) then
        local boundary = gen_boundary()
        body = encode(t, boundary)
        content_type = fmt("multipart/form-data; boundary=%s", boundary)
    else
        body = _M.gen_common_params(t)
        content_type = "application/x-www-form-urlencoded"
    end
    return body, content_type
end

--[===[
请求参数：
{
    url = "", -- 请求链接
    version = "1.1" -- http版本, 目前支持 1.0 or 1.1.
    method = "POST", -- http方法, 默认：GET
    timeout = timeout, -- 请求超时时间，默认：30秒
    headers = { content-type="application/x-www-form-urlencoded" }, -- 请求头信息
    params = { a="1", b="2" }, -- 请求参数
    body = "", -- 请求体
    keepalive = true, -- 是否保持连接
    keepalive_timeout = 600000, -- 连接池超时时间
    keepalive_pool = 256 -- 连接池大小
}
返回结果：
res_status, res_headers, res_body
--]===]
function _M.request_http(reqTable)
    -- 参数校验
    if _.isEmpty(reqTable)
            or not _.isTable(reqTable)
            or _.isEmpty(reqTable["url"]) then
        return nil, "IllegalArgument."
    end
    -- 设置默认值
    reqTable = _.defaults(reqTable, {
        method = "GET",
        timeout = 60000,
        keepalive = true,
        keepalive_timeout = 300000, -- 单位是ms
        keepalive_pool = 256
    })
    -- 处理参数和头信息
    if not _.isEmpty(reqTable["params"]) then
        if reqTable["method"] == "GET" then
            local queryString = _M.gen_common_params(reqTable["params"])
            local pos_s, pos_e = string.find(reqTable["url"], "?")
            if pos_s == nil then
                reqTable["url"] = reqTable["url"] .. "?" .. queryString
            else
                reqTable["url"] = reqTable["url"] .. "&" .. queryString
            end
        else
            local body, content_type = _M.gen_post_params(reqTable["params"])
            reqTable["body"] = body
            reqTable["headers"]["Content-Type"] = content_type
        end
    end
    -- 请求http
    local http_instance = http:new()
    http_instance:set_timeout(reqTable["timeout"])
    local res, err = http_instance:request_uri(reqTable["url"], reqTable)
    if err == "closed" then
        ngx.log(logger.e("request_http connection closed，retry"))
        res, err = http_instance:request_uri(reqTable["url"], reqTable)
    end
    if not res then
        ngx.log(logger.e("request_http fail，url=", reqTable["url"], ", err=", err))
        return 500, nil, err
    end
    return res.status, res.headers, res.body
end

return _M