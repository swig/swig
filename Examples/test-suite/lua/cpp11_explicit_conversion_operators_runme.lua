local l=require("cpp11_explicit_conversion_operators")

local u=l.U()
u.u = 11
local v=l.V()
v.v = 22
local t1=l.TestClass(u)
assert(t1.t == 11)
local t2=l.TestClass(v)
assert(t2.t == 22)

local t = l.Testable()
assert(t:AsInteger() == 42)
-- TODO function for bool casting
