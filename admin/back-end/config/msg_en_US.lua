--[[
普通消息
local message = luastar_context.get_msg("100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.get_msg("100002"):format(100.00)
--]]
msg = {
    ["100001"] = "Error1！", --
    ["100002"] = "amount can't greate then %d yuan！", --
    ["100003"] = "Error3！", --
    ["199999"] = nil
}