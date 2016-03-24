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
mysql_uc = {
    class = "luastar.db.mysql",
    arg = {
        { value = "${mysql}" }
    }
}
redis_uc = {
    class = "luastar.db.redis",
    arg = {
        { value = "${redis}" }
    }
}


