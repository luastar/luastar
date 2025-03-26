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
  single = 0  -- 是否单例，默认是1
}
--]]
-- mysql = {
--     class = "db.mysql",
--     arg = {
--         { value = "${mysql}" }
--     }
-- }

-- redis = {
--     class = "db.redis",
--     arg = {
--         { value = "${redis}" }
--     }
-- }


