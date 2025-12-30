local ngx = require "ngx"
local balancer = require "ngx.balancer"
local balance_alg = require "core.balance"
local config = require "core.config"

-- 获取下一台服务器
local function get_next_server(project, mode, servers)
  -- 获取运行的服务器列表（current_weight, effective_weight）
  local dict = ngx.shared.dict_ls_configs
  local dict_key = project .. ":servers"
  local servers_info_str = dict:get(dict_key)
  -- 合并服务器信息
  if not _.isEmpty(servers_info_str) then
    local servers_info = cjson.decode(servers_info_str)
    for i, srv in ipairs(servers) do
      for j, srv_info in ipairs(servers_info) do
        if (srv["host"] .. ":" .. srv["port"]) == (srv_info["host"] .. ":" .. srv_info["port"]) then
          srv["current_weight"] = srv_info["current_weight"]
          srv["effective_weight"] = srv_info["effective_weight"]
          break
        end
      end
    end
  end
  -- 根据策略获取下一台要访问的服务器
  local next_server_func = balance_alg.next_round_robin_server
  local hash_key = ngx.var.uri
  if mode ~= "rr" then
    if mode == "hash" then
      hash_key = ngx.var.uri
    elseif mode == "url_hash" then
      hash_key = ngx.var.uri
    elseif mode == "ip_hash" then
      hash_key = ngx.var.remote_addr
    elseif mode == "header_hash" then
      hash_key = ngx.var.http_x_hash_key or ngx.var.uri
    end
    next_server_func = balance_alg.next_consistent_hash_server
  end
  local server = next_server_func(
    servers,
    function(index, srv) return true end,
    hash_key
  )
  -- 保存服务器运行信息
  dict:set(dict_key, cjson.encode(servers))
  return server
end

do
  -- 获取当前要访问的项目
  local project = ngx.ctx.proxy_project or ngx.var.http_x_proxy_project
  if _.isEmpty(project) then
    logger.error("代理项目未配置！")
    return
  end
  -- 获取项目配置信息
  local project_config = config.get_config(project)
  -- 负载均衡策略 hash, url_hash, ip_hash, header_hash, rr
  local mode = project_config["mode"]
  if not mode or mode == "" then mode = "rr" end
  -- 配置的服务器列表（host, post, weight）
  local servers = project_config["servers"]
  if _.isEmpty(servers) or not _.isTable(servers) then
    logger.error("代理项目[servers]属性未正确配置！")
    return
  end
  -- 获取需要访问的服务器
  local server = get_next_server(project, mode, servers)
  if _.isEmpty(server)
      or _.isEmpty(server["host"])
      or _.isEmpty(server["port"]) then
    logger.error("代理项目[", project, "]服务器选择失败，检查[host]和[port]属性是否配置！")
    return
  end
  -- 设置访问超时时间
  local connect_timeout = project_config["connect_timeout"] or 6000
  local send_timeout = project_config["send_timeout"] or 600000
  local read_timeout = project_config["read_timeout"] or 600000
  local ok, err = balancer.set_timeouts(connect_timeout, send_timeout, read_timeout)
  if not ok then
    logger.error("failed to set timeouts : ", err)
  end
  -- 设置当前要访问的服务器
  local ok, err = balancer.set_current_peer(server["host"], server["port"])
  if not ok then
    logger.error("failed to set the current peer : ", err)
    return
  end
  -- 开启保持连接
  local ok, err = balancer.enable_keepalive(60, 100)
  if not ok then
    logger.error("failed to enable keepalive : ", err)
  end
end
