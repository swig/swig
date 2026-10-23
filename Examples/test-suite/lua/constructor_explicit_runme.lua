local v=require("constructor_explicit")

local f = v.Foo()
assert(swig_type(f) == "Foo *")
f = v.Foo(12)
assert(swig_type(f) == "Foo *")
local f2 = v.test(f)
assert(swig_type(f2) == "Foo *")
