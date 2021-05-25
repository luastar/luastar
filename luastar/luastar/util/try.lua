--[[
https://github.com/djfdyuruiry/lua-try-catch-finally

local try = require "try"
local object
try(function ()
    object = Object()
    object:doRiskyStuff()
end)
.catch(function (ex)
    print(ex)
end)
.finally(function ()
    if object then
        object:dispose()
    end
end)

--]]

local function_type = "function"

---
-- @param try_block The block of code to execute as the try block.
--
-- @return A table that can be used to chain try/catch/finally blocks. (Call .catch or .finally of the return value)
--
local function try(try_block)
    local status, err = true, nil

    if type(try_block) == function_type then
        status, err = xpcall(try_block, debug.traceback)
    end

    local finally = function(finally_block, catch_block_declared)
        if type(finally_block) == function_type then
            finally_block()
        end

        if not catch_block_declared and not status then
            error(err)
        end
    end

    local catch = function(catch_block)
        local catch_block_declared = type(catch_block) == function_type;

        if not status and catch_block_declared then
            local ex = err or "unknown error occurred"
            catch_block(ex)
        end

        return {
            finally = function(finally_block)
                finally(finally_block, catch_block_declared)
            end
        }
    end

    return {
        catch = catch,
        finally = function(finally_block)
            finally(finally_block, false)
        end
    }
end

return try