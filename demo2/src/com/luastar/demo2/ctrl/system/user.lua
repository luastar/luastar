--[[

--]]
local _M = {}

local str_util = require("luastar.util.str")
local constant = require("com.luastar.demo2.util.constant")
local json_util = require("com.luastar.demo2.util.json")
local layout_util = require("com.luastar.demo2.util.layout")

function _M.index(request, response)
	-- 输出
	local funcId = request:get_arg("funcId")
	local view = template.new("system/user/user.html", layout_util.getLayout(funcId))
	view:render()
end

function _M.list(request, response)
	local page = tonumber(_.ifEmpty(request:get_arg("page"), 1))
	local limit = tonumber(_.ifEmpty(request:get_arg("limit"), 20))
	local param = {
		start = (page - 1) * limit,
		limit = limit,
		keyword = request:get_arg("query_username")
	}
	-- 查询结果
	local beanFactory = luastar_context.getBeanFactory()
	local userService = beanFactory:getBean("userService")
	local num = userService:countUser(param);
	local data = {}
	if num > 0 then
		data = userService:getUserList(param);
	end
	-- 返回结果
	local result = {
		code = 0,
		msg = "ok",
		count = num,
		data = data
	}
	response:writeln(json_util.toJson(result, true))
end

function _M.edit(request, response)
	local id = tonumber(request:get_arg("id"))
	local beanFactory = luastar_context.getBeanFactory()
	local userService = beanFactory:getBean("userService")
	local userRoleRelationService = beanFactory:getBean("userRoleRelationService")
	local user, userRoleList = {}, {}
	if id == nil or id == 0 then
		-- 新增
		user = userService:getEmptyUser()
	else
		-- 修改
		user = userService:getUserById(id);
		userRoleList = userRoleRelationService:getUserRoleRelationList({ userId = id })
	end
	-- 角色列表
	local roleService = beanFactory:getBean("roleService")
	local roleList = roleService:getRoleList()
	template.render("system/user/user_edit.html", {
		user = user,
		userRoleList = userRoleList,
		roleList = roleList
	})
end

function _M.save(request, response)
	local user = {
		id = request:get_arg("id"),
		loginName = request:get_arg("loginName"),
		userName = request:get_arg("userName"),
		pazzword = request:get_arg("pazzword"),
		roles = request:get_arg("roles")
	}
	-- 校验
	if _.isEmpty(user["loginName"]) then
		response:writeln(json_util.fail("登录名不能为空！"))
		return
	end
	if _.isEmpty(user["roles"]) then
		response:writeln(json_util.fail("请至少选择一个角色！"))
		return
	end
	-- 用户是否存在
	local beanFactory = luastar_context.getBeanFactory()
	local userService = beanFactory:getBean("userService")
	if userService:existUser(user["id"], user["loginName"]) then
		response:writeln(json_util.fail("用户已存在！"))
		return
	end
	local userRoleArray = str_util.split(user["roles"], ",")
	local userRoleRelationService = beanFactory:getBean("userRoleRelationService")
	if _.isEmpty(user["id"]) or tonumber(user["id"]) == 0 then
		-- 新增
		user["isEffective"] = constant["EFFECTIVE_YES"]
		user["pazzword"] = str_util.md5(user["pazzword"] or "123456")
		local userId = userService:insert(user);
		_.eachArray(userRoleArray, function(i, roleId)
			userRoleRelationService:insert({
				userId = userId,
				roleId = roleId
			})
		end)
	else
		-- 修改
		if not _.isEmpty(user["pazzword"]) then
			user["pazzword"] = str_util.md5(user["pazzword"])
		end
		userService:update(user);
		userRoleRelationService:deleteByUserId(user["id"])
		_.eachArray(userRoleArray, function(i, roleId)
			userRoleRelationService:insert({
				userId = user["id"],
				roleId = roleId
			})
		end)
	end
	response:writeln(json_util.success("保存成功！"))
end

return _M