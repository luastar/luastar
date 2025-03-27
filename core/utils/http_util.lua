--[[
    http 客户端工具
--]]
local _M = {}

local http = require("resty.http")

-- 私有方法 
-- 格式化字符串
local fmt = function(p, ...)
    if select('#', ...) == 0 then
        return p
    else
        return string.format(p, ...)
    end
end

-- 私有方法
-- 表中添加一个格式化的字符串
local tprintf = function(t, p, ...)
    t[#t + 1] = fmt(p, ...)
end

-- 私有方法
-- 追加文件数据
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

-- 私有方法
-- 将请求参数编码为 multipart/form-data 格式
local encode_form_data_params = function(t, boundary)
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

-- 私有方法
-- 判断是否包含文件
local hasfile = function(t)
    local has_file = false
    for k, v in pairs(t) do
        if type(v) == "table" then
            has_file = true
            break
        end
    end
    return has_file
end

-- 私有方法
-- 生成随机的 boundary
local gen_boundary = function()
    local t = { "BOUNDARY-" }
    for i = 2, 17 do 
        t[i] = string.char(math.random(65, 90)) 
    end
    t[18] = "-BOUNDARY"
    return table.concat(t)
end

-- 公有方法
-- 将请求参数编码为 application/x-www-form-urlencoded 格式
function _M.encode_form_params(t)
    local body = {}
    for k, v in pairs(t) do
        body[#body + 1] = k .. "=" .. v
    end
    return table.concat(body, "&")
end

-- 公有方法
-- 参数编码
function _M.encode_params(t)
    local body, content_type
    if hasfile(t) then
        local boundary = gen_boundary()
        body = encode_form_data_params(t, boundary)
        content_type = fmt("multipart/form-data; boundary=%s", boundary)
    else
        body = _M.encode_form_params(t)
        content_type = "application/x-www-form-urlencoded"
    end
    return body, content_type
end

--[===[
请求参数：
{
    url = "", -- 请求链接
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
function _M.request(options)
    -- 参数校验
    if _.isEmpty(options)
            or not _.isTable(options)
            or _.isEmpty(options["url"]) then
        return nil, "参数错误！"
    end
    -- 设置默认值
    options = _.defaults(options, {
        method = "GET",
        timeout = 60000,
        headers = {},
        keepalive = true,
        keepalive_timeout = 600000, -- 单位是ms
        keepalive_pool = 512
    })
    -- 设置 trace_id
    options["headers"]["trace_id"] = ngx.ctx.trace_id
    -- 处理参数和头信息
    if not _.isEmpty(options["params"]) then
        if options["method"] == "GET" then
            local query_string = _M.encode_form_params(options["params"])
            local pos_s, pos_e = string.find(options["url"], "?")
            if pos_s == nil then
                options["url"] = options["url"] .. "?" .. query_string
            else
                options["url"] = options["url"] .. "&" .. query_string
            end
        else
            local body, content_type = _M.encode_params(options["params"])
            options["body"] = body
            options["headers"]["Content-Type"] = content_type
        end
    end
    -- 请求http
    local http_instance = http:new()
    http_instance:set_timeout(options["timeout"])
    local res, err = http_instance:request_uri(options["url"], options)
    if err == "closed" then
        logger.error("request_http connection closed，retry")
        res, err = http_instance:request_uri(options["url"], options)
    end
    if not res then
        logger.error("request_http fail，url=", options["url"], ", err=", err)
        return 500, nil, err
    end
    return res.status, res.headers, res.body
end

return _M