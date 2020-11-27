--[[

--]]
local _M = {}

local layout_util = require("com.luastar.demo2.util.layout")

function _M.index(request, response)
	-- 输出
	local view = template.new("index.html", layout_util.getLayout())
	view.message = "Welcome！"
	view:render()
end

return _M