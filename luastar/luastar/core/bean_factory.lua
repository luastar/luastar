--[[
应用bean工厂，类似于spring bean容器
--]]

local util_file = require("luastar.util.file")
local util_str = require("luastar.util.str")

local BeanFactory = luastar_class("luastar.core.BeanFactory")
local bean_status = { init_ing = 1, init_ok = 2, init_fail = 3 }

function BeanFactory:init(config_file)
	-- ngx.log(ngx.INFO, "[BeanFactory:init] file : ", config_file)
	self.config_file = config_file
	if not self.config_file then
		ngx.log(ngx.ERR, "[BeanFactory:init] illegal argument : config_file can't nil.")
		return
	end
	self.config = util_file.loadlua_nested(self.config_file) or {}
	-- single bean cache
	self.bean_cache = {}
end

function BeanFactory:get_bean_obj(id, ctime)
	local bean_config = self.config[id] or {}
	if bean_config.single == 0 then
		return self:create_bean(id, ctime)
	end
	local bean = self.bean_cache[id]
	if not bean then
		bean = self:create_bean(id, ctime)
		self.bean_cache[id] = bean
		return bean
	end
	return bean
end

function BeanFactory:get_bean(id)
	local bean = self:get_bean_obj(id)
	if not bean then
		return nil
	end
	if bean.status == bean_status.init_ok then
		return bean.obj
	end
	return nil
end

function BeanFactory:get_ref(id, ctime)
	local bean = self:get_bean_obj(id, ctime)
	if not bean then
		return nil
	end
	if bean.status == bean_status.init_ok then
		return bean.obj
	end
	return nil
end

function BeanFactory:create_bean(id, ctime)
	if not ctime then ctime = {} end -- 一次创建bean的时机，记录依赖bean的状态
	local bean = { id = id, status = bean_status.init_ing }
	if ctime[id] == bean_status.init_ing then
		bean.status = bean_status.init_fail
		ctime[id] = nil
		ngx.log(ngx.ERR, "[BeanFactory:create_bean] id ", id, " has circular dependency.")
		return bean
	end
	ctime[id] = bean_status.init_ing
	local bean_config = self.config[id] or {}
	ngx.log(ngx.DEBUG, "[BeanFactory:create_bean] ", id, " config : " .. cjson.encode(bean_config))
	if not bean_config.class then
		bean.status = bean_status.init_fail
		ctime[id] = nil
		ngx.log(ngx.ERR, "[BeanFactory:create_bean] ", id, " config class is null.")
		return bean
	end
	local ok, bean_class = pcall(require, bean_config.class)
	if not ok then
		bean.status = bean_status.init_fail
		ctime[id] = nil
		ngx.log(ngx.ERR, "[BeanFactory:create_bean] ", id, "  require class fail.")
		ngx.log(ngx.ERR, bean_class)
		return bean
	end
	-- create bean obj
	local bean_obj
	if bean_config.arg then
		local bean_arg = {}
		_.each(bean_config.arg, function(index, arg)
			if arg.value then
				table.insert(bean_arg, self:get_value(arg.value))
			elseif arg.ref then
				table.insert(bean_arg, self:get_ref(arg.ref, ctime))
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
					pcall(method, bean_obj, self:get_value(property.value))
				elseif property.ref then
					pcall(method, bean_obj, self:get_ref(property.ref, ctime))
				else
					ngx.log(ngx.WARN, "[BeanFactory:create_bean] ", id, " property[", property.name, "] value is nil.")
				end
			else
				ngx.log(ngx.WARN, "[BeanFactory:create_bean] ", id, " method[", property.name, "] not exist.")
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

function BeanFactory:get_value(key)
	local var = string.match(key, "${.+}")
	if not var then
		ngx.log(ngx.DEBUG, "[BeanFactory:get_value] key[", key, "] value : ", key)
		return key
	end
	var = string.sub(var, 3, string.len(var) - 1) -- sub ${}
	local var_ary = util_str.split(var, "%.")
	local var_len = _.size(var_ary)
	local val = luastar_config.get_config(var_ary[1])
	if var_len == 1 then
		ngx.log(ngx.DEBUG, "[BeanFactory:get_value] key[", key, "] value : ", cjson.encode(val))
		return val
	end
	local var_ary2 = _.last(var_ary, var_len - 1)
	local rs = _.reduce(var_ary2, function(s, v)
		return s[v]
	end, val)
	ngx.log(ngx.DEBUG, "[BeanFactory:get_value] key[", key, "] value : ", cjson.encode(rs))
	return rs
end

return BeanFactory
