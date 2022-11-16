--[[
提示消息配置
普通消息
local message = luastar_context.get_msg("msg_live", "100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.get_msg("msg_live", "100002"):format(100.00)
多级配置消息获取方法
local message = luastar_context.get_msg("msg_live", "100003", "001")
--]]
msg_pub = {
    ["100001"] = "Error1！", --
    ["100002"] = "amount can't greate then %d yuan！", --
    ["100003"] = {
        ["001"] = "Error3-1！", --
        ["002"] = "Error3-2"
    }, --
    ["199999"] = nil
}
msg_uc = {
    ["200001"] = "Error1！", --
    ["200002"] = "Error2！", --
    ["200003"] = "Error3！", --
    ["299999"] = nil
}