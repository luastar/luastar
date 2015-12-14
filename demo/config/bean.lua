#!     /usr/bin/env lua
--[[
id = {
  class = "",
  arg = {
    {value/ref = ""}
  },
  property = {
    {name = "",value/ref = ""}
  },
  init_method = "",
  single = 0  -- default 1
}
--]]
mysql = {
    class = "luastar.db.mysql",
    arg = {
        { value = "${mysql}" }
    }
}
redis = {
    class = "luastar.db.redis",
    arg = {
        { value = "${redis}" }
    }
}
paramService = {
    class = "com.lajin.service.common.paramService"
}
testService = {
    class = "com.lajin.service.test.testService",
    arg = { { ref = "redis" } }
}


