--[[

--]]
local _M = {}

local str_util = require("luastar.util.str")

local function renderLogin(message)
    template.render("login.html", {
        message = message
    })
end

--[[
 用户登录
--]]
function _M.login(request, response)
    local param = {
        username = request:get_arg("username"),
        password = request:get_arg("password")
    }
    -- 参数校验
    if _.isEmpty(param["username"]) or _.isEmpty(param["password"]) then
        renderLogin("Enter any username and password.")
        return
    end
    -- 数据库密码校验
    local beanFactory = luastar_context.getBeanFactory()
    local userService = beanFactory:getBean("userService")
    local userInfo = userService:getUserByName(param["username"])
    if _.isEmpty(userInfo) then
        renderLogin("user not exist.")
        return
    end
    if not str_util.equalsIgnoreCase(str_util.md5(param["password"]), userInfo["pazzword"]) then
        renderLogin("password error.")
        return
    end
    -- 保存session
    ngx.log(logger.i("保存session: ", cjson.encode(userInfo)))
    session.save("user", userInfo)
    -- 返回首页
    response:redirect("/", 302)
end

--[[
 用户注销
--]]
function _M.logout(request, response)
    -- 销毁session
    session.destroy()
    -- 返回登录页面
    renderLogin()
end

return _M