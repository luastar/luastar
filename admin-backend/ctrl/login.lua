--[[

--]]

local res_util = require("utils.res_util")

local _M = {}

--[[
 用户登录
--]]
function _M.login(request, response)
    local data;
    local username = request:get_arg("username");
    if username == "admin" then
        data = {
            avatar = "https://avatars.githubusercontent.com/u/44761321",
            username = "admin",
            nickname = "嘟啊嘟",
            roles = {"admin"},
            permissions = {"*:*:*"},
            accessToken = "eyJhbGciOiJIUzUxMiJ9.admin",
            refreshToken = "eyJhbGciOiJIUzUxMiJ9.adminRefresh",
            expires = "2030/10/30 00:00:00"
        };
    else
        data = {
            avatar = "https://avatars.githubusercontent.com/u/44761321",
            username = "common",
            nickname = "嘟小嘟",
            roles = {"common"},
            permissions = {"permission:btn:add", "permission:btn:edit"},
            accessToken = "eyJhbGciOiJIUzUxMiJ9.common",
            refreshToken = "eyJhbGciOiJIUzUxMiJ9.commonRefresh",
            expires = "2030/10/30 00:00:00"
        };
    end
    response:set_content_type_json()
    response:writeln(res_util.success(data))
end

return _M