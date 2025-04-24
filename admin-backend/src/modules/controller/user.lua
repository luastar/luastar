--[===[
  用户模块
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"

local _M = {}

function _M.handle(params)
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
  ngx.ctx.response:set_content_type_json();
  ngx.ctx.response:writeln(res_util.success(data));
end

return _M
