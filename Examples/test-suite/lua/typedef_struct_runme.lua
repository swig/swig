local v=require("typedef_struct")

local x = v.LineObj()
x.numpoints = 100
assert(x.numpoints == 100)
assert(v.MS_NOOVERRIDE == -1111)
local y = v.make_a()
y.a = 200
assert(y.a == 200)
y.b = 300
assert(y.b == 300)
