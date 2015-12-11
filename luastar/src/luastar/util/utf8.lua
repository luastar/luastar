#!  /usr/bin/env lua
--[[
https://github.com/starwing/luautf8
--]]
module(..., package.seeall)

local utf8 = require("lua-utf8")

function byte(...)
    return utf8.byte(...)
end

function char(...)
    return utf8.char(...)
end

function find(...)
    return utf8.find(...)
end

function gmatch(...)
    return utf8.gmatch(...)
end

function gsub(...)
    return utf8.gsub(...)
end

function len(...)
    return utf8.len(...)
end

function lower(...)
    return utf8.lower(...)
end

function match(...)
    return utf8.match(...)
end

function reverse(...)
    return utf8.reverse(...)
end

function reverse(...)
    return utf8.reverse(...)
end

function sub(...)
    return utf8.sub(...)
end

function upper(...)
    return utf8.upper(...)
end

--[===[
utf8.escape(str) -> utf8 string
--]===]
function escape(str)
    return utf8.escape(str)
end

--[===[
utf8.charpos(s[[, charpos], offset]) -> charpos, code point
--]===]
function charpos(s, charpos, offset)
    return utf8.charpos(s, charpos, offset)
end

--[===[
utf8.next(s[, charpos[, offset]]) -> charpos, code point
--]===]
function next(s, charpos, offset)
    return utf8.next(s, charpos, offset)
end

--[===[
utf8.insert(s[, idx], substring) -> new_string
--]===]
function insert(s, idx, substring)
    return utf8.insert(s, idx, substring)
end

--[===[
utf8.remove(s[, start[, stop]]) -> new_string
--]===]
function remove(s, start, stop)
    return utf8.remove(s, start, stop)
end

--[===[
utf8.width(s[, ambi_is_double[, default_width]]) -> width
--]===]
function width(s, ambi_is_double, default_width)
    return utf8.width(s, ambi_is_double, default_width)
end

--[===[
utf8.widthindex(s, location[, ambi_is_double[, default_width]]) -> idx, offset, width
--]===]
function widthindex(s, location, ambi_is_double, default_width)
    return utf8.widthindex(s, location, ambi_is_double, default_width)
end

--[===[
utf8.title(s) -> new_string
--]===]
function title(s)
    return utf8.title(s)
end

--[===[
utf8.fold(s) -> new_string
convert UTF-8 string s to title-case, or folded case used to compare by ignore case. if s is a number,
it's treat as a code point and return a convert code point (number). utf8.lower/utf8.upper has the
same extension.
--]===]
function fold(s)
    return utf8.fold(s)
end

--[===[
utf8.ncasecmp(a, b) -> [-1,0,1]
compare a and b without case, -1 means a < b, 0 means a == b and 1 means a > b.
--]===]
function ncasecmp(a, b)
    return utf8.ncasecmp(a, b)
end