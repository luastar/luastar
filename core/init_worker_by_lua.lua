--[[
    在 ngx_lua 模块 init_worker_by_lua_file 阶段执行;
--]]

-- 间隔时间
local delay = 10
-- 定时任务
local ngx_timer_at = ngx.timer.at
local handler

handler = function(premature)
    if not premature then
        -- 定时任务
        local ok, err = ngx_timer_at(delay, handler)
        if not ok then
            logger.error("failed to create timer: ", err)
            return
        end
    end
    -- do something in timer
    logger.info("worker定时任务执行中...")
end

-- 只有第0个 worker 才执行
if ngx.worker.id() == 0 then
    local ok, err = ngx_timer_at(delay, handler)
    if not ok then
        logger.error("failed to create timer: ", err)
        return
    end
end
