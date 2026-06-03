local v=require("overload_subtype")

local f = v.Foo()
local b = v.Bar()
assert(v.spam(f) == 1, "foo")
assert(v.spam(b) == 2, "bar")
