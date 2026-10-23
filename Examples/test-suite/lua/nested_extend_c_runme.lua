local v=require("nested_extend_c")

local hi = v.hiA()
assert(hi:hi_extend() == 'h')
local low = v.lowA()
assert(low:low_extend() == 99)
local hi = v.hiB()
assert(hi:hi_extend() == 'h')
local low = v.lowB()
assert(low:low_extend() == 99)
local foobar = v.FOO().bar
foobar.d = 1234
assert(foobar.d == 1234)
foobar:bar_extend()
