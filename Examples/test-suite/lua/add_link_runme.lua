require("add_link")

local a = add_link.Foo()
assert(a ~= nil)
assert(swig_type(a) == "Foo *")
local b = a:blah()
assert(b ~= nil)
assert(swig_type(b) == "Foo *")
assert(b ~= a) -- b is a new Foo object!
