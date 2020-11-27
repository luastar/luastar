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
userService = {
    class = "com.luastar.demo2.service.system.userService"
}
funcService = {
    class = "com.luastar.demo2.service.system.funcService"
}
roleService = {
    class = "com.luastar.demo2.service.system.roleService"
}
userRoleRelationService = {
    class = "com.luastar.demo2.service.system.userRoleRelationService"
}
