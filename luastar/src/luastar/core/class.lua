--[[
-- 简化版class，不推荐在lua里使用继承
-- 详细可参考cocos2d-x
https://github.com/cocos2d/cocos2d-x/blob/f99dae383f861533ab657fc241d1105e558c618d/cocos/scripting/lua-bindings/script/cocos2d/functions.lua
--]]
local class = function(classname)
	local cls = {}
	cls.__cname = classname
	cls.__index = cls
	cls.new = function(self, ...)
		local instance = { class = self }
		setmetatable(instance, self)
		-- 执行初始化方法
		if instance.init and type(instance.init) == "function" then
			instance:init(...)
		end
		return instance
	end
	-- 支持定义出来的类使用『 类名()』方法创建实现
	setmetatable(cls, { __call = function(self, ...) return self:new(...) end })
	return cls
end

-- 支持使用local a = class("com.luastar.a")定义类
return setmetatable({}, { __call = function(self, ...) return class(...) end })