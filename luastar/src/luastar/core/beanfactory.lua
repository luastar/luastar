#!    /usr/bin/env lua
--[[
应用bean工厂，类似于spring bean容器
--]]

local util_file = require("luastar.util.file")
local util_str = require("luastar.util.str")

local BeanFactory = Class("luastar.core.BeanFactory")
local bean_status = { init_ing = 1, init_ok = 2, init_fail = 3 }

function BeanFactory:init(config_file)
    ngx.log(ngx.DEBUG, "[BeanFactory:init] file : ", config_file)
    self.config_file = config_file
    if not self.config_file then
        ngx.log(ngx.ERR, "[BeanFactory:init] illegal argument : config_file can't nil.")
        return
    end
    self.config = util_file.loadlua(self.config_file) or {}
    -- single bean cache
    self.beanCache = {}
end

function BeanFactory:getBeanObj(id, ctime)
    local bean_config = self.config[id] or {}
    if bean_config.single == 0 then
        return self:createBean(id, ctime)
    end
    local bean = self.beanCache[id]
    if not bean then
        bean = self:createBean(id, ctime)
        self.beanCache[id] = bean
        return bean
    end
    return bean
end

function BeanFactory:getBean(id)
    local bean = self:getBeanObj(id)
    if not bean then
        return nil
    end
    if bean.status == bean_status.init_ok then
        return bean.obj
    end
    return nil
end

function BeanFactory:getRef(id, ctime)
    local bean = self:getBeanObj(id, ctime)
    if not bean then
        return nil
    end
    if bean.status == bean_status.init_ok then
        return bean.obj
    end
    return nil
end

function BeanFactory:createBean(id, ctime)
    if not ctime then ctime = {} end -- 一次创建bean的时机，记录依赖bean的状态
    local bean = { id = id, status = bean_status.init_ing }
    if ctime[id] == bean_status.init_ing then
        bean.status = bean_status.init_fail
        ctime[id] = nil
        ngx.log(ngx.ERR, "[BeanFactory:createBean] id ", id, " has circular dependency.")
        return bean
    end
    ctime[id] = bean_status.init_ing
    local bean_config = self.config[id] or {}
    ngx.log(ngx.DEBUG, "[BeanFactory:createBean] ", id, " config : " .. cjson.encode(bean_config))
    if not bean_config.class then
        bean.status = bean_status.init_fail
        ctime[id] = nil
        ngx.log(ngx.ERR, "[BeanFactory:createBean] ", id, " config class is null.")
        return bean
    end
    local ok, bean_class = pcall(require, bean_config.class)
    if not ok then
        bean.status = bean_status.init_fail
        ctime[id] = nil
        ngx.log(ngx.ERR, "[BeanFactory:createBean] ", id, "  require class fail.")
        ngx.log(ngx.ERR, bean_class)
        return bean
    end
    -- create bean obj
    local bean_obj
    if bean_config.arg then
        local bean_arg = {}
        _.each(bean_config.arg, function(index, arg)
            if arg.value then
                table.insert(bean_arg, self:getValue(arg.value))
            elseif arg.ref then
                table.insert(bean_arg, self:getRef(arg.ref, ctime))
            end
        end)
        bean_obj = bean_class:new(unpack(bean_arg))
    else
        bean_obj = bean_class:new()
    end
    -- set bean obj property
    if bean_config.property then
        _.each(bean_config.property, function(index, property)
            local method = bean_obj["set_" .. property.name]
            if _.isCallable(method) then
                if property.vale then
                    pcall(method, bean_obj, self:getValue(property.value))
                elseif property.ref then
                    pcall(method, bean_obj, self:getRef(property.ref, ctime))
                else
                    ngx.log(ngx.WARN, "[BeanFactory:createBean] ", id, " property[", property.name, "] value is nil.")
                end
            else
                ngx.log(ngx.WARN, "[BeanFactory:createBean] ", id, " method[", property.name, "] not exist.")
            end
        end)
    end
    if bean_config.init_method then
        pcall(bean_obj[init_method])
    end
    bean.obj = bean_obj
    bean.status = bean_status.init_ok
    ctime[id] = nil
    return bean
end

function BeanFactory:getValue(key)
    local var = string.match(key, "${.+}")
    if not var then
        ngx.log(ngx.DEBUG, "[BeanFactory:getValue] key[", key, "] value : ", key)
        return key
    end
    var = string.sub(var, 3, string.len(var) - 1) -- sub ${}
    local varAry = util_str.split(var, "%.")
    local varLen = _.size(varAry)
    local val = luastar_config.getConfig(varAry[1])
    if varLen == 1 then
        ngx.log(ngx.DEBUG, "[BeanFactory:getValue] key[", key, "] value : ", cjson.encode(val))
        return val
    end
    local varAry2 = _.last(varAry, varLen - 1)
    local rs = _.reduce(varAry2, function(s, v)
        return s[v]
    end, val)
    ngx.log(ngx.DEBUG, "[BeanFactory:getValue] key[", key, "] value : ", cjson.encode(rs))
    return rs
end

return BeanFactory
