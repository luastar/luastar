--[[
    系统功能服务类
--]]
local FuncService = Class()

local sql_util = require("luastar.util.sql")

function FuncService:init()
end

function FuncService:funcResultMap(result)
    if _.isEmpty(result) then
        return nil
    end
    return {
        id = result["ID"],
        funcName = result["FUNC_NAME"],
        parentFuncId = result["PARENT_FUNC_ID"],
        isLeaf = result["IS_LEAF"],
        actionUrl = result["ACTION_URL"],
        iconUrl = result["ICON_URL"],
        funcOrder = result["FUNC_ORDER"],
        isEffective = result["IS_EFFECTIVE"],
        createdTime = result["CREATED_TIME"],
        updatedTime = result["UPDATED_TIME"]
    }
end

function FuncService:getFuncInfoById(id)
    if _.isEmpty(id) then
        return nil
    end
    local sql = "select * from SYS_FUNCTION where ID=" .. id
    local beanFactory = luastar_context.getBeanFactory()
    local mysql_util = beanFactory:getBean("mysql")
    local mysql = mysql_util:getConnect()
    local res, err, errno, sqlstate = mysql:query(sql)
    mysql_util:close(mysql)
    if _.isEmpty(res) then
        return nil
    end
    return self:funcResultMap(res[1])
end

function FuncService:getParentFuncIdList(fid)
    local parentFuncIdList = {}
    local func = self:getFuncInfoById(fid);
    if _.isEmpty(func) then
        return parentFuncIdList
    end
    local parentFuncId = func["parentFuncId"]
    while not _.isEmpty(parentFuncId) and parentFuncId ~= 0 and not _.contains(parentFuncIdList, parentFuncId) do
        local parentFunc = self:getFuncInfoById(parentFuncId)
        if _.isEmpty(parentFunc) then
            return parentFuncIdList
        end
        table.insert(parentFuncIdList, parentFuncId)
        parentFuncId = parentFunc["parentFuncId"]
    end
    return parentFuncIdList;
end

function FuncService:getUserFuncList(userId, parentFuncId)
    if _.isEmpty(userId) or _.isEmpty(parentFuncId) then
        return nil
    end
    local sql_table = {
        sql = [[
            select a.*
			from SYS_FUNCTION a
			where a.ID in (
				select b.FUNC_ID
				from SYS_ROLE_FUNCTION_RELATION b
				where b.ROLE_ID in (
					select c.ROLE_ID
					from SYS_USER_ROLE_RELATION c
					where c.USER_ID=#{userId}
				)
				group by b.FUNC_ID
			)
			and a.IS_EFFECTIVE=1
			and a.PARENT_FUNC_ID=#{parentFuncId}
			order by a.FUNC_ORDER
        ]]
    }
    local data = { userId = userId, parentFuncId = parentFuncId }
    local sql = sql_util.getsql(sql_table, data)
    local beanFactory = luastar_context.getBeanFactory()
    local mysql_util = beanFactory:getBean("mysql")
    local mysql = mysql_util:getConnect()
    local res, err, errno, sqlstate = mysql:query(sql)
    mysql_util:close(mysql)
    if _.isEmpty(res) then
        return nil
    end
    return _.mapArray(res, function(i, v)
        return self:funcResultMap(v)
    end)
end

--function FuncService:isFuncActive(func, funcId, parentFuncIdList)
--	if _.isEmpty(func) or _.isEmpty(funcId) then
--		return false
--	end
--	-- 如果是叶子节点，直接判断id是否相同
--	if func["isLeaf"] == 1 then
--		return func["id"] == tonumber(funcId)
--	end
--	-- 非叶子节点，查看是否在父节点中
--	if not _.isEmpty(parentFuncIdList) and _.contains(parentFuncIdList, func["id"]) then
--		return true
--	end
--	return false
--end

function FuncService:getUserSubFuncList(userId, funcList, funcId, parentFuncIdList)
    if _.isEmpty(funcList) then
        return nil
    end
    -- 递归获取子功能
    return _.mapArray(funcList, function(i, v)
        v["isActive"] = (v["id"] == tonumber(funcId))
        v["isOpen"] = false
        if not _.isEmpty(parentFuncIdList) and _.contains(parentFuncIdList, v["id"]) then
            v["isOpen"] = true
        end
        local subFuncList = self:getUserFuncList(userId, v["id"])
        v["subFuncList"] = self:getUserSubFuncList(userId, subFuncList, funcId, parentFuncIdList)
        return v
    end)
end

--[[
查询用户有权限的功能菜单
userId 登录用户Id
funcId 当前菜单id
--]]
function FuncService:getUserAllFuncList(userId, funcId)
    local funcList = self:getUserFuncList(userId, 0)
    if _.isEmpty(funcList) then
        return nil
    end
    local parentFuncIdList = self:getParentFuncIdList(funcId)
    return self:getUserSubFuncList(userId, funcList, funcId, parentFuncIdList)
end

--[[
功能节点输出
--]]
function FuncService:getUserSidebar(userId, funcId)
    local treeList = {}
    local indexLiClass = "layui-nav-item"
    if _.isEmpty(funcId) or funcId == 0 then
        indexLiClass = indexLiClass .. " layui-this"
    end
    table.insert(treeList, string.format([[<li class="%s">]], indexLiClass))
    table.insert(treeList, [[<a href="/">首页</a>]])
    table.insert(treeList, [[</li>]])
    local funcList = self:getUserAllFuncList(userId, funcId)
    if _.isEmpty(funcList) then
        return table.concat(treeList, "\n")
    end
    for i, func in ipairs(funcList) do
        local liClass = "layui-nav-item"
        if not _.isEmpty(func["subFuncList"]) and func["isOpen"] then
            liClass = liClass .. " layui-nav-itemed"
        end
        if func["isActive"] then
            liClass = liClass .. " layui-this"
        end
        local url = "javascript:;"
        if func["isLeaf"] == 1 then
            url = func["actionUrl"] .. "?funcId=" .. func["id"]
        end
        table.insert(treeList, string.format([[<li class="%s">]], liClass))
        table.insert(treeList, string.format([[<a href="%s">%s</a>]], url, func["funcName"]))
        -- 递归输出子节点，目前只支持两级
        self:getUserSidebarTree(func["subFuncList"], treeList)
        table.insert(treeList, [[</li>]])
    end
    return table.concat(treeList, "\n")
end

function FuncService:getUserSidebarTree(funcList, treeList)
    if _.isEmpty(funcList) then
        return
    end
    table.insert(treeList, [[<dl class="layui-nav-child">]])
    _.mapArray(funcList, function(i, func)
        local ddClass = ""
        if func["isActive"] then
            ddClass = ddClass .. " layui-this"
        end
        local url = "javascript:;"
        if func["isLeaf"] == 1 then
            url = func["actionUrl"] .. "?funcId=" .. func["id"]
        end
        table.insert(treeList, string.format([[<dd class="%s">]], ddClass))
        table.insert(treeList, string.format([[<a href="%s">%s</a>]], url, func["funcName"]))
        table.insert(treeList, string.format([[</dd>]]))
        -- 目前只支持两级
        -- 递归输出子节点
        -- self:getUserSidebarTree(func["subFuncList"], treeList)
    end)
    table.insert(treeList, [[</dl]])
end

return FuncService
