--[[
普通消息
local message = luastar_context.get_msg("100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.get_msg("100002"):format(100.00)
--]]
local msg = {
    ["100001"] = "错误1！", --
    ["100002"] = "金额不能超过%d元！", --
    ["100003"] = "错误3！",
    ["199999"] = nil
}

return {
    msg = msg
}
