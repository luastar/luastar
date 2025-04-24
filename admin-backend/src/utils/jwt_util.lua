--[[
jwt 验证工具

payload 标准 claims：
iss(Issuser)：JWT的签发主体；
sub(Subject)：JWT的主体，即它的所有人；
aud(Audience)：JWT的接收对象；
exp(Expiration time)：时间戳，JWT的过期时间；
nbf(Not Before)：时间戳，JWT的生效开始时间；
iat(lssued at)：时间戳，代表这个JWT的签发时间；
jti(JWT ID)：JWT的唯一标识

--]]
local cjson = require "cjson"
local jwt = require "resty.jwt"

local _M = {}

-- 签名
function _M.sign(secret, payload)
    local jwt_token = jwt:sign(secret,
        {
            header = { typ = "JWT", alg = "HS256" },
            payload = payload
        }
    )
    return jwt_token
end

-- 验证
function _M.verify(secret, token)
    return jwt:verify(secret, token)
end

return _M
