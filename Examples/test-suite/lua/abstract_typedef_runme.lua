local v=require("abstract_typedef")

local e = v.Engine()
assert(e ~= nil)
local a = v.A()
assert(a ~= nil)
assert(a:write(e))
