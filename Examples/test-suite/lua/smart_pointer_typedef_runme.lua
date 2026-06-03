local v=require("smart_pointer_typedef")

local f = v.Foo()
local b = v.Bar(f)

b.x = 3
assert(b:getx() == 3)

local fp = b:__deref__()
assert(fp:getx() == 3)
fp.x = 4
assert(fp:getx() == 4)
