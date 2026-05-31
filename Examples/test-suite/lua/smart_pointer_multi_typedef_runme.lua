local v=require("smart_pointer_multi_typedef")

local f = v.Foo()
local b = v.Bar(f)
local s = v.Spam(b)
local g = v.Grok(b)

s.x = 3
assert(s:getx() == 3)
g.x = 4
assert(g:getx() == 4)
