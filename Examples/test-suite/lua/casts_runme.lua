require("casts")

local a = casts.A()
assert(a ~= nil)
assert(swig_type(a) == "A *")
a:hello()


-- Make sure b inherits hello() from class A
local b = casts.B()
assert(b ~= nil)
assert(swig_type(b) == "B *")
b:hello()
