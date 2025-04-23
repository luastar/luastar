--[[
https://github.com/jkeys089/lua-resty-hmac
修改适配 OpenSSL 1.1.0+ 以上版本
--]]

local str_util = require "resty.string"
local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_gc = ffi.gc
local C = ffi.C
local setmetatable = setmetatable

local _M = { _VERSION = '0.02' }
local mt = { __index = _M }

ffi.cdef [[
typedef struct HMAC_CTX HMAC_CTX;
HMAC_CTX *HMAC_CTX_new(void);
void HMAC_CTX_free(HMAC_CTX *ctx);
int HMAC_Init_ex(HMAC_CTX *ctx, const void *key, int len, const void *md, void *impl);
int HMAC_Update(HMAC_CTX *ctx, const unsigned char *data, size_t len);
int HMAC_Final(HMAC_CTX *ctx, unsigned char *md, unsigned int *len);
const void *EVP_md5(void);
const void *EVP_sha1(void);
const void *EVP_sha256(void);
const void *EVP_sha512(void);
]]

local buf = ffi_new("unsigned char[64]")
local res_len = ffi_new("unsigned int[1]")

local hashes = {
    MD5 = C.EVP_md5(),
    SHA1 = C.EVP_sha1(),
    SHA256 = C.EVP_sha256(),
    SHA512 = C.EVP_sha512()
}

_M.ALGOS = hashes

function _M.new(self, key, hash_algo)
    local ctx = C.HMAC_CTX_new()
    if ctx == nil then
        return nil, "failed to allocate HMAC_CTX"
    end
    ffi_gc(ctx, C.HMAC_CTX_free)
    local _hash_algo = hash_algo or hashes.MD5
    if C.HMAC_Init_ex(ctx, key, #key, _hash_algo, nil) ~= 1 then
        return nil, "HMAC_Init_ex failed"
    end
    return setmetatable({ _ctx = ctx }, mt)
end

function _M.update(self, s)
    return C.HMAC_Update(self._ctx, s, #s) == 1
end

function _M.final(self, s, hex_output)
    if s ~= nil then
        if C.HMAC_Update(self._ctx, s, #s) == 0 then
            return nil, "final update failed"
        end
    end
    if C.HMAC_Final(self._ctx, buf, res_len) == 1 then
        local result = ffi_str(buf, res_len[0])
        if hex_output then
            return str_util.to_hex(result)
        end
        return result
    end
    return nil, "HMAC_Final failed"
end

function _M.reset(self)
    return C.HMAC_Init_ex(self._ctx, nil, 0, nil, nil) == 1
end

return _M
