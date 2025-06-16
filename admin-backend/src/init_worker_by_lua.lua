--[[
    在 ngx_lua 模块 init_worker_by_lua_file 阶段执行
--]]
local ngx = require "ngx"
local ngx_timer_at = ngx.timer.at
local ngx_timer_every = ngx.timer.every

-- 处理器
local handler1
local handler2

-- 处理器实现
handler1 = function(premature)
  -- 循环执行
  if not premature then
    local ok, err = ngx_timer_at(30, handler1)
    if not ok then
      logger.error("failed to create timer : ", err)
      return
    end
  end
  -- 定时同步 mysql 数据到 dict
  logger.info("[init_worker]开始同步数据到字典...")
  local data_sync = require "core.data_sync"
  data_sync.sync_db_to_dict()
end

handler2 = function(premature)
  if premature then
    return
  end
  -- 定时同步 dict 数据到 mysql
  logger.info("[init_worker]开始同步数据到数据库...")
  local data_sync = require "core.data_sync"
  data_sync.sync_dict_to_db()
end

do
  -- 仅保持一个 worker 执行
  if ngx.worker.id() == 0 then
    local ok, err = ngx_timer_at(0, handler1)
    if not ok then
      logger.error("failed to create timer : ", err)
      return
    end
    local ok, err = ngx_timer_every(60, handler2)
    if not ok then
      logger.error("failed to create timer : ", err)
      return
    end
  end
end
