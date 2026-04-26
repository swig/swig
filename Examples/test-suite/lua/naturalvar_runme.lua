local v=require("naturalvar")

local f = v.Foo()
local b = v.Bar()

b.f = f
v.s = "hello"
b.s = "hello"
assert(b.s == v.s)
