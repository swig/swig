local v=require("cpp11_using_typedef_struct")

local b = v.AffineMatrix()
b.z = 1
b.y = b.z
b.x = b.y

assert(v.fn1(b) == b.x)

local bb = v.xCacheView()
bb.x = 123

assert(v.fn2(bb) == 123)
