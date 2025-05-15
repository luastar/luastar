--[[
	异常工具
  直接使用 error(str) 抛出异常，在 pxcall 中获取到的异常信息会包含抛出异常的文件堆栈信息，
  这里包装一下，抛出 table 类型，获取时只获取 str 信息
--]]

local _M = {}

function _M.throw(msg)
  error({
    message = msg,
    traceback = debug.traceback() -- 保留完整堆栈用于日志
  }, 2)                           -- 2表示跳过当前函数栈
end

function _M.get_msg(err)
  if type(err) == "table" and err.message then
    return err.message
  end
  return err
end

return _M
