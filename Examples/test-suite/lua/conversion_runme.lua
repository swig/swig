require("conversion")

local bar=conversion.Bar()
assert(bar ~= nil)
assert(swig_type(bar) == "Bar *")
local foo=bar:toFoo()
assert(foo ~= nil)
assert(swig_type(foo) == "Foo *")
