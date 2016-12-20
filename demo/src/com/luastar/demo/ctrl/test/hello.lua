--[[

--]]
local _M = {}

--[[
 获取普通参数/文件参数/请求体例子
--]]
function _M.hello(request, response)
    -- request:get_arg 支持获取get,post（含文件）方式传过来的参数
    local name = request:get_arg("name") or "world, try to give a param with name."
    ngx.log(logger.i("name=", name))
    -- 获取到的文件类型是table类型，包含filename（文件名）和value（文件内容）属性
    local file = request:get_arg("file")
    if not _.isEmpty(file) then
        local file_save = io.open("/Users/zhuminghua/Downloads/output/"..file["filename"],"w")
        file_save:write(file["value"]);
        file_save:close();
    end
    -- 获取到的request_body类型，注意如果client_max_body_size和client_body_buffer_size不一致，
    -- 请求体超过client_body_buffer_size nginx会缓存到文件中，如果请求体比较大，建议将两者设置成一致
    local request_body = request:get_request_body()
--    local file_save = io.open("/Users/zhuminghua/Downloads/output/aaa.jpg","w")
--    file_save:write(request_body);
--    file_save:close();
    response:writeln("hello, " .. name)
end

--[[
 输出图片
--]]
function _M.pic(request, response)
    local file = io.open("/Users/zhuminghua/Desktop/测试/图像/01/pic_001.jpg","rb")
    local file_content = file:read("*a")
    file:close()
    --[[
        application/octet-stream 二进制流，不知道下载文件类型
    --]]
    response:set_header("Content-Type","image/jpeg")
    response:set_header("Cache-Control","no-store, no-cache, must-revalidate")
    response:set_header("Pragma","no-cache")
    response:write(file_content)
end

return _M