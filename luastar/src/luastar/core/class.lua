local baseMt = {
    __call = function(self, ...)
        return self:new(...)
    end
}

local _class = function(classname, super)
    local super_type = type(super)
    if super_type ~= "function" and super_type ~= "table" then
        super = nil
    end
    local cls = {}
    if super then
        baseMt.__index = super
        cls.super = super
    end
    cls.new = function(self, ...)
        local instance = { class = self }
        setmetatable(instance, self)
        if instance.init and type(instance.init) == "function" then
            instance:init(...)
        end
        return instance
    end
    cls.__cname = classname
    cls.__index = cls
    setmetatable(cls, baseMt)
    return cls
end

local class = {}
return setmetatable(class, { __call = function(...) return _class(...) end })