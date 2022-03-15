--[[
    输入参数检验
--]]
local ParamService = luastar_class("com.luastar.demo.service.common.ParamService")

local str_util = require("luastar.util.str")
local table_util = require("luastar.util.table")

function ParamService:init()
end

function ParamService:getHeadParam()
    local request = ngx.ctx.request
    local param = {}
    param["appkey"] = request:get_header("appkey") or ""
    param["appversion"] = request:get_header("apiversion") or ""
    param["ostype"] = request:get_header("ostype") or 2
    param["osrelease"] = request:get_header("osrelease") or ""
    param["sign"] = request:get_header("sign") or ""
    return param
end

function ParamService:checkSign(checkParam)
    -- 输入sign
    local request = ngx.ctx.request
    local sign = request:get_header("sign")
    -- ngx.log(logger.i("sign input is ", sign))
    -- 输入参数（不为空的）
    local param_array = {}
    if type(checkParam) == "string" then
        param_array = str_util.split("&")
    elseif type(checkParam) == "table" then
        param_array = table_util.table2arr(checkParam)
    end
    -- 按参数名排序
    table.sort(param_array)
    -- 拼接密钥
    local param_base = table.concat(param_array) .. "UJMpkYFiq4YDMLkEXgqYUltbfWCb7p67"
    -- ngx.log(logger.i("sign str is ", param_base))
    -- url编码
    local param_encode = str_util.encode_url(param_base)
    -- ngx.log(logger.i("sign urlencode is ", param_encode))
    -- 计算md5
    local param_md5 = str_util.md5(param_encode)
    -- ngx.log(logger.i("sign md5 is ", param_md5))
    -- 对比sign
    if sign == param_md5 then
        return true
    end
    -- 暂不校验sign
    -- return false
    return true
end

return ParamService
