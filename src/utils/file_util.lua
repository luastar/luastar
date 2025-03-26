--[[
	文件工具
--]]
local _M = {}

-- 加载LUA文件
function _M.load_lua(file)
	ngx.log(ngx.INFO, "加载LUA文件：", file)
	-- 加载指定路径下的Lua代码文件（不会执行）
	local fct = assert(loadfile(file))
	-- 设置全局环境变量
	local env = setmetatable({}, { __index = _G })
	setfenv(fct, env)
	-- 执行Lua文件中全局部分的代码
	assert(pcall(fct))
	setmetatable(env, nil)
	return env
end

-- 加载LUA字符串
function _M.load_lua_str(str)
	ngx.log(ngx.INFO, "加载LUA字符串：", str)
	local fct = assert(loadstring(str))
	local env = setmetatable({}, { __index = _G })
	setfenv(fct, env)
	assert(pcall(fct))
	setmetatable(env, nil)
	return env
end

-- 加载JSON文件
function _M.load_json(file)
	ngx.log(ngx.INFO, "加载JSON文件：", file)
	-- 读取文件内容
    local f = assert(io.open(file, "r"))
    local content = f:read("*a")
    f:close()
    -- 解析JSON内容
    local ok, result = pcall(require("cjson").decode, content)
    if not ok then
        ngx.log(ngx.ERR, "解析JSON文件失败：", result)
        return nil
    end
    return result
end

return _M