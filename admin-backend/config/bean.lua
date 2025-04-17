--[[
id = { -- bean id
  class = "", -- 类地址
  arg = { -- 构造参数注入
    {value/ref = ""} -- value赋值，ref引用其他bean
  },
  property = { -- set方法注入，实现set_${name}方法
    {name = "",value/ref = ""}
  },
  init_method = "", -- 初始化方法，默认使用init()
  single = true  -- 是否单例，默认为 true
}
--]]

local mysql_service = {
  class = "db.mysql",
  arg = {
    { value = "${mysql_config}" }
  }
}

local redis_service = {
  class = "db.redis",
  arg = {
    { value = "${redis_config}" }
  }
}

return {
  mysql_service = mysql_service,
  redis_service = redis_service
}
