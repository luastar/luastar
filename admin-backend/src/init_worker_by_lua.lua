--[[
    在 ngx_lua 模块 init_worker_by_lua_file 阶段执行
--]]
local ngx = require "ngx"
local ngx_timer_at = ngx.timer.at

-- 处理器
local handler

-- 处理器实现
handler = function(premature)
  -- 循环执行
  if not premature then
    local ok, err = ngx_timer_at(60, handler)
    if not ok then
      logger.error("failed to create timer : ", err)
      return
    end
  end
  -- 定时同步 mysql 数据到 dict
  logger.info("[init_worker]开始同步数据...")
  local data_sync = require "core.data_sync"
  data_sync.sync()
end

do
  -- 仅保持一个 worker 执行
  if ngx.worker.id() == 0 then
    local ok, err = ngx_timer_at(0, handler)
    if not ok then
      logger.error("failed to create timer : ", err)
      return
    end
  end
end
