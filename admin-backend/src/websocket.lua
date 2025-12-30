local ngx = require "ngx"
local server = require "resty.websocket.server"

-- 创建 WebSocket 服务器实例
local wb, err = server:new {
  timeout = 60000,        -- 超时时间（毫秒）
  max_payload_len = 65535 -- 最大消息长度
}
if not wb then
  logger.error("failed to new websocket: ", err)
  return ngx.exit(ngx.HTTP_CLOSE) -- 关闭连接
end

-- 主消息循环
while true do
  -- 接收客户端消息
  local data, typ, err = wb:recv_frame()
  if not data then
    logger.error("failed to receive a frame: ", err)
    if not string.find(err, "timeout", 1, true) then
      break
    end
  end
  if typ == "close" then
    -- 处理关闭帧
    local bytes, err = wb:send_close()
    if not bytes then
      logger.error("failed to send close frame: ", err)
    end
    break
  elseif typ == "ping" then
    -- 处理 ping 帧，自动回复 pong
    local bytes, err = wb:send_pong()
    if not bytes then
      logger.error("failed to send pong frame: ", err)
    end
  elseif typ == "pong" then
    -- 处理 pong 帧（通常无需特殊处理）
    logger.info("received pong frame")
  else
    -- 处理文本或二进制消息
    logger.info("received message: ", data)
    -- 回复消息
    local bytes, err = wb:send_text("Server received: " .. data)
    if not bytes then
      logger.error("failed to send text: ", err)
      break
    end
  end
end

-- -- 定时推送消息
-- local thread = ngx.thread.spawn(function()
--   while true do
--     -- 模拟定时推送
--     ngx.sleep(5) -- 每5秒推送一次
--     local ok, err = wb:send_text("Server heartbeat: " .. os.date())
--     if not ok then
--       logger.error("failed to send heartbeat: ", err)
--       break
--     end
--   end
-- end)

-- -- 等待协程结束
-- ngx.thread.wait(thread)
