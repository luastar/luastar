--[[
	页面布局工具
--]]

local _M = {}

--[[
-- 获取默认的页面布局及数据填充
--]]
function _M.getLayout(funcId)
	-- 登录用户信息
	local userInfo = session.getData("user")
	-- 功能菜单
	local beanFactory = luastar_context.getBeanFactory()
	local funcService = beanFactory:getBean("funcService")
	local sidebar = funcService:getUserSidebar(userInfo["id"], funcId)
	-- 布局
	local layout = template.new("layouts/layout.html")
	layout.username = userInfo["userName"]
	layout.sidebar = sidebar
	return layout
end

return _M



