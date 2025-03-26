--[[
表工具
--]]
local _M = {}

local ok, new_tab = pcall(require, "table.new")
if not ok then new_tab = function(narr, nrec) return {} end end

_M.new_tab = new_tab

--[[
-- 将 redis 结果中的数组转换成 hash 结构
--]]
function _M.array_to_hash(t)
	if not t or not _.isArray(t) then
		return nil
	end
	local n = #t
	local h = new_tab(0, n / 2)
	for i = 1, n, 2 do
		h[t[i]] = t[i + 1]
	end
	return h
end

return _M