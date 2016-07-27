#!  /usr/bin/env lua
--[[
	
]]
module(..., package.seeall)

local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function(narr, nrec) return {} end
end

function array_to_hash(t)
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

function table2str(t, s)
    local t_arr = _.values(_.map(t, function(k, v) return k .. "=" .. v end))
    return table.concat(t_arr, s or "")
end

function table2arr(t, s)
    local seq = s or "="
    return _.values(_.map(t, function(k, v) return k .. seq .. tostring(v) end))
end