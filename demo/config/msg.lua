--[[
提示消息配置
普通消息
local message = luastar_context.getMsg("msg_live", "100001")
占位直接使用string的格式化方法，例如%s, %d等
local message = luastar_context.getMsg("msg_live", "100002"):format(100.00)
多级配置消息获取方法
local message = luastar_context.getMsg("msg_live", "100003", "001")
--]]
msg_pub = {
    ["100001"] = "错误1！", --
    ["100002"] = "金额不能超过%d元！", --
    ["100003"] = {
        ["001"] = "错误3-1！", --
        ["002"] = "错误3-2"
    }, --
    ["199999"] = nil
}
msg_uc = {
    ["200001"] = "错误1！", --
    ["200002"] = "错误2！", --
    ["200003"] = "错误3！", --
    ["299999"] = nil
}