--[===[
  用户模块
--]===]
local ngx = require "ngx"
local res_util = require "utils.res_util"

local _M = {}

function _M.get_async_routes(params)
  local data = {

  };
  ngx.ctx.response:set_content_type_json();
  ngx.ctx.response:writeln(res_util.success(data));
end

return _M
