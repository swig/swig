local v=require("smart_pointer_const")

local f = v.Foo()
local b = v.Bar(f) -- holds pointer to 'f'
b.x = 3
assert(b:getx() == 3)

local fp = b:__deref__() -- get point of 'f'
assert(fp:getx() == 3)
fp.x = 4
assert(fp:getx() == 4)
