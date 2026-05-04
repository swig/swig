local v=require("cpp14_auto_return_type")

local sc = v.va_static_cast()
assert(sc == 42, "va_static_cast")

local x = v.X()
local a = x:a()
assert(a == "a string", "x.a")
