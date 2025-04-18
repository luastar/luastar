--[[
用户相关接口
--]]

local res_util = require "utils.res_util"

local _M = {}

--[[
 获取前端路由
--]]
function _M.handle(request, response)
    local data = {
        {
            path = "/permission",
            meta = {
                title = "menus.purePermission",
                icon = "ep:lollipop",
                rank = 10
            },
            children = {
                {
                    path = "/permission/page/index",
                    name = "PermissionPage",
                    meta = {
                        title = "menus.purePermissionPage",
                        roles = { "admin", "common" }
                    }
                },
                {
                    path = "/permission/button",
                    meta = {
                        title = "menus.purePermissionButton",
                        roles = { "admin", "common" }
                    },
                    children = {
                        {
                            path = "/permission/button/router",
                            component = "permission/button/index",
                            name = "PermissionButtonRouter",
                            meta = {
                                title = "menus.purePermissionButtonRouter",
                                auths = {
                                    "permission:btn:add",
                                    "permission:btn:edit",
                                    "permission:btn:delete"
                                }
                            }
                        },
                        {
                            path = "/permission/button/login",
                            component = "permission/button/perms",
                            name = "PermissionButtonLogin",
                            meta = {
                                title = "menus.purePermissionButtonLogin"
                            }
                        }
                    }
                }
            }
        }
    };
    response:set_content_type_json();
    response:writeln(res_util.success(data));
end

return _M
