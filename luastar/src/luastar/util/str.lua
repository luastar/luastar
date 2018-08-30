--[[

--]]
local _M = {}

function _M.trim(str)
    return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

function _M.split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

function _M.equalsIgnoreCase(str1, str2)
    if str1 == str2 then
        return true
    end
    if str1 and str2 and string.upper(str1) == string.upper(str2) then
        return true
    end
    return false
end

function _M.containsIgnoreCase(str1, str2)
    if str1 == str2 then
        return true
    end
    if str1 and str2 and string.find(string.upper(str1), string.upper(str2)) ~= nil then
        return true
    end
    return false
end

function _M.startsWith(str, substr)
    if str == nil or substr == nil then
        return false
    end
    if string.find(str, substr) ~= 1 then
        return false
    else
        return true
    end
end

function _M.endsWith(str, substr)
    if str == nil or substr == nil then
        return false
    end
    local str_tmp, substr_tmp = string.reverse(str), string.reverse(substr)
    if string.find(str_tmp, substr_tmp) ~= 1 then
        return false
    else
        return true
    end
end

function _M.indexOf(str, substr)
    return string.find(str, substr, 1, true)
end

function _M.lastIndexOf(str, substr)
    return string.match(str, '.*()' .. substr)
end

function _M.uri_is_macth(uri_req, uri_config, is_pattern)
    if is_pattern then
        -- 模糊匹配
        local is, ie = string.find(uri_req, uri_config)
        if is ~= nil then
            return true
        end
    else
        -- 全匹配
        if uri_req == uri_config or uri_req == uri_config .. "/" then
            return true
        end
    end
    return false
end

function _M.method_and_uri_is_macth(method_req, uri_req, method_config, uri_config, is_pattern)
    if is_pattern then
        -- 模糊匹配
        if method_config == "*" or _M.containsIgnoreCase(method_config, method_req) then
            local is, ie = string.find(uri_req, uri_config)
            if is ~= nil then
                return true
            end
        end
    else
        -- 全匹配
        if method_config == "*" or _M.containsIgnoreCase(method_config, method_req) then
            if uri_req == uri_config or uri_req == uri_config .. "/" then
                return true
            end
        end
    end
    return false
end

function _M.fmtstring(str, data)
    -- 找出所有${}变量
    local varAry = {}
    for word in string.gmatch(str, "%${[%w_]+}") do
        local var = string.sub(word, 3, string.len(word) - 1) -- sub ${}
        table.insert(varAry, var)
    end
    -- 替换变量
    for i, key in ipairs(varAry) do
        local value = data[key]
        if value ~= nil then
            value = string.gsub(tostring(value), "%%", "%%%%")
            str = string.gsub(str, "${" .. key .. "}", value)
        end
    end
    return str
end

function _M.encode_url(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            --str = string.gsub (str, "([^%w %-%_%.%!%~%*%'%(%,%)])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

function _M.decode_url(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)",
        function(h) return string.char(tonumber(h, 16)) end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end

-- encode base64  
function _M.encode_base64(str)
    return ngx.encode_base64(str)
end

-- decode base64  
function _M.decode_base64(str)
    return ngx.decode_base64(str)
end

-- md5 
function _M.md5(str)
    return ngx.md5(str)
end

-- sha1
function _M.sha1(str)
    local resty_str = require("resty.string")
    return resty_str.to_hex(ngx.sha1_bin(str))
end

-- hmac_sha1
function _M.hmac_sha1(secret_key, str)
    local resty_str = require("resty.string")
    return resty_str.to_hex(ngx.hmac_sha1(secret_key, str))
end

return _M