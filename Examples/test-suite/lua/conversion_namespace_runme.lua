local v=require("conversion_namespace")

local bar=v.Bar()
assert(bar ~= nil)
assert(swig_type(bar) == "oss::Bar *")
local foo=bar:toFoo()
assert(foo ~= nil)
assert(swig_type(foo) == "oss::Foo *")
