#!  /usr/bin/env lua
--[[

--]]
module(..., package.seeall)

function split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0 -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function startsWith(str, substr)
    if str == nil or substr == nil then
        return false
    end
    if string.find(str, substr) ~= 1 then
        return false
    else
        return true
    end
end

function endsWith(str, substr)
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

function indexOf(str, substr)
    return string.find(str, substr, 1, true)
end

function lastIndexOf(str, substr)
    return string.match(str, '.*()' .. substr)
end

function trim(str)
    return str:match '^()%s*$' and '' or str:match '^%s*(.*%S)'
end

function encode_url(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])",
            --str = string.gsub (str, "([^%w %-%_%.%!%~%*%'%(%,%)])",
            function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

function decode_url(str)
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)",
        function(h) return string.char(tonumber(h, 16)) end)
    str = string.gsub(str, "\r\n", "\n")
    return str
end

-- encode base64  
function encode_base64(str)
    return ngx.encode_base64(str)
end

-- decode base64  
function decode_base64(str)
    return ngx.decode_base64(str)
end

-- md5 
function md5(str)
    return ngx.md5(str)
end

-- sha1
function sha1(str)
    local resty_str = require("resty.string")
    return resty_str.to_hex(ngx.sha1_bin(str))
end

function isNil(val)
    if val == nil then return true end
    if type(val) == 'string' then return #val == 0 end
    if type(val) == 'table' then return _.size(val) == 0 end
    if type(val) == 'userdata' then return true end
    return false
end
	
