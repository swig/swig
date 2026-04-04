local tnt=require("template_nested_typemaps")

local b = tnt.BreezeString()
local v = 88
local vTypemap = -99
assert(b:methodInt1(v) == v)
assert(b:methodInt2(v) == vTypemap)
assert(tnt.globalInt1(v) == v)
assert(tnt.globalInt2(v) == v)
assert(tnt.globalInt3(v) == vTypemap)
v = 88
vTypemap = -77
assert(b:methodShort1(v) == v)
assert(b:methodShort2(v) == vTypemap)
assert(tnt.globalShort1(v) == v)
assert(tnt.globalShort2(v) == v)
assert(tnt.globalShort3(v) == vTypemap)
