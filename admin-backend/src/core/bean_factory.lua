--[[
	Bean工厂，类似于 Spring Bean 容器
--]]

local file_util = require "utils.file_util"
local str_util = require "utils.str_util"

local _M = {}
local mt = { __index = _M }

local bean_status = { init_ing = 1, init_ok = 2, init_fail = 3 }

-- 初始化
function _M:new(config_file)
  if not config_file then
    logger.error("config_file can't nil.")
    return
  end
  local instance = {
    config_file = config_file,
    config = file_util.load_lua(config_file) or {},
    bean_cache = {}
  }
  return setmetatable(instance, mt)
end

-- 获取 bean 实例
function _M:get_bean_obj(id, ctime)
  local bean_config = self.config[id] or {}
  if not bean_config["single"] then
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

-- 获取 bean 实例
function _M:get_bean(id)
  local bean = self:get_bean_obj(id)
  if not bean then
    return nil
  end
  if bean.status == bean_status.init_ok then
    return bean.obj
  end
  return nil
end

-- 获取 bean 依赖
function _M:get_ref(id, ctime)
  local bean = self:get_bean_obj(id, ctime)
  if not bean then
    return nil
  end
  if bean.status == bean_status.init_ok then
    return bean.obj
  end
  return nil
end

-- 创建 bean 实例
function _M:create_bean(id, ctime)
  if not ctime then ctime = {} end -- 一次创建bean的时机，记录依赖bean的状态
  local bean = { id = id, status = bean_status.init_ing }
  if ctime[id] == bean_status.init_ing then
    bean.status = bean_status.init_fail
    ctime[id] = nil
    logger.error(id, " has circular dependency.")
    return bean
  end
  ctime[id] = bean_status.init_ing
  local bean_config = self.config[id] or {}
  if not bean_config["class"] then
    bean["status"] = bean_status.init_fail
    ctime[id] = nil
    logger.error(id, " config class is null.")
    return bean
  end
  local ok, bean_class = pcall(require, bean_config["class"])
  if not ok then
    bean.status = bean_status.init_fail
    ctime[id] = nil
    logger.error(id, "  require class fail.")
    logger.error(bean_class)
    return bean
  end
  -- create bean obj
  local bean_obj
  if bean_config.arg then
    local bean_arg = {}
    for k, v in pairs(bean_config.arg) do
      if v.value then
        table.insert(bean_arg, self:get_value(v.value))
      elseif v.ref then
        table.insert(bean_arg, self:get_ref(v.ref, ctime))
      end
    end
    bean_obj = bean_class:new(unpack(bean_arg))
  else
    bean_obj = bean_class:new()
  end
  -- set bean obj property
  if bean_config.property then
    for k, v in pairs(bean_config.property) do
      local method = bean_obj["set_" .. v.name]
      if _.isCallable(method) then
        if v.vale then
          pcall(method, bean_obj, self:get_value(v.value))
        elseif v.ref then
          pcall(method, bean_obj, self:get_ref(v.ref, ctime))
        else
          logger.warn(id, " property[", v.name, "] value is nil.")
        end
      else
        logger.warn(id, " method[", v.name, "] not exist.")
      end
    end
  end
  if bean_config.init_method then
    pcall(bean_obj.init_method)
  end
  bean.obj = bean_obj
  bean.status = bean_status.init_ok
  ctime[id] = nil
  return bean
end

-- 获取配置值
function _M:get_value(key)
  local var = string.match(key, "${.+}")
  if not var then
    return key
  end
  var = string.sub(var, 3, string.len(var) - 1) -- sub ${}
  local var_ary = str_util.split(var, "%.")
  local var_len = _.size(var_ary)
  local val = ls_cache.get_config(var_ary[1])
  if var_len == 1 then
    return val
  end
  local var_ary2 = _.last(var_ary, var_len - 1)
  local rs = _.reduce(var_ary2, function(s, v)
    return s[v]
  end, val)
  return rs
end

return _M
