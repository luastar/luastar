--[===[
  参考实现 ： https://github.com/upyun/slardar
--]===]

local ceil         = math.ceil
local floor        = math.floor
local str_byte     = string.byte
local table_sort   = table.sort
local table_insert = table.insert

local _M           = { _VERSION = "0.0.1" }

local MOD          = 2 ^ 32
local REPLICAS     = 20
local LUCKY_NUM    = 13

--[[
下一个轮询服务器
parameters:
    - (table) servers
    - (function) peer_cb(index, server)
return:
    - (table) server
    - (string) error
--]]
function _M.next_round_robin_server(servers, peer_cb)
  local srvs_cnt = #servers
  -- 只有一台服务器
  if srvs_cnt == 1 then
    if peer_cb(1, servers[1]) then
      return servers[1], nil
    end
    return nil, "round robin: no servers available"
  end
  -- 选择轮询服务器
  local best
  local max_weight
  local weight_sum = 0
  for idx = 1, srvs_cnt do
    local srv = servers[idx]
    -- init round robin state
    srv["weight"] = srv["weight"] or 1
    srv["effective_weight"] = srv["effective_weight"] or srv["weight"]
    srv["current_weight"] = srv["current_weight"] or 0
    if peer_cb(idx, srv) then
      srv["current_weight"] = srv["current_weight"] + srv["effective_weight"]
      weight_sum = weight_sum + srv["effective_weight"]
      if srv["effective_weight"] < srv["weight"] then
        srv["effective_weight"] = srv["effective_weight"] + 1
      end
      if not max_weight or srv["current_weight"] > max_weight then
        max_weight = srv["current_weight"]
        best = srv
      end
    end
  end
  if not best then
    return nil, "round robin: no servers available"
  end
  best.current_weight = best.current_weight - weight_sum
  return best, nil
end

--[[
  释放轮询服务器
--]]
function _M.free_round_robin_server(srv, failed)
  if not failed then
    return
  end
  srv["effective_weight"] = ceil((srv["effective_weight"] or 1) / 2)
end

--[[
  计算字符串的哈希值
--]]
local function hash_string(str)
  local key = 0
  for i = 1, #str do
    key = (key * 31 + str_byte(str, i)) % MOD
  end
  return key
end

--[[
  初始化一致性哈希状态
--]]
local function init_consistent_hash_state(servers)
  -- 计算总权重
  local weight_sum = 0
  for _, srv in ipairs(servers) do
    weight_sum = weight_sum + (srv["weight"] or 1)
  end
  -- 初始化哈希环
  local circle, members = {}, 0
  for index, srv in ipairs(servers) do
    local key = ("%s:%s"):format(srv["host"], srv["port"])
    local base_hash = hash_string(key)
    -- 生成虚拟节点
    for c = 1, REPLICAS * weight_sum do
      local hash = (base_hash * c * LUCKY_NUM) % MOD -- TODO: more balance hash
      table_insert(circle, { hash, index })
    end
    members = members + 1
  end
  -- 排序哈希环
  table_sort(circle, function(a, b) return a[1] < b[1] end)
  return { circle = circle, members = members }
end

--[[
  二分查找算法
  在有序环形数组 circle 中，查找第一个大于或等于 key 的元素的索引。
--]]
local function binary_search(circle, key)
  local size = #circle
  local st, ed = 1, size
  while st <= ed do
    local mid = floor((st + ed) / 2)
    if circle[mid][1] < key then
      st = mid + 1
    else
      ed = mid - 1
    end
  end
  return st == size + 1 and 1 or st
end

--[[
  下一个一致性哈希服务器
--]]
function _M.next_consistent_hash_server(servers, peer_cb, hash_key)
  servers.chash = _.isTable(servers.chash)
      and servers.chash
      or init_consistent_hash_state(servers)
  local chash = servers.chash
  -- 如果只有一个服务器
  if chash.members == 1 then
    if peer_cb(1, servers[1]) then
      return servers[1]
    end
    return nil, "consistent hash: no servers available"
  end
  local circle = chash.circle
  local st = binary_search(circle, hash_string(hash_key))
  local size = #circle
  local ed = st + size - 1
  for i = st, ed do -- TODO: algorithm O(n)
    local idx = circle[(i - 1) % size + 1][2]
    if peer_cb(idx, servers[idx]) then
      return servers[idx]
    end
  end
  return nil, "consistent hash: no servers available"
end

--[[
  释放一致性哈希服务器
--]]
function _M.free_consitent_hash_server(srv, failed)
  return
end

return _M
