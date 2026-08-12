local v=require("cpp14_auto_return_type")

local sc = v.va_static_cast()
assert(sc == 42, "va_static_cast")

local x = v.X()
local a = x:a()
assert(a == "a string", "x.a")

local c = x:cref()
assert(c == 42, "x.cref")

local d = v.Deduced(7)
assert(d:toInt() == 7, "Deduced.toInt")
