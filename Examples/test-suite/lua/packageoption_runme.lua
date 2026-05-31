require("packageoption_a")
require("packageoption_b")

local a = packageoption_a.A()
assert(swig_type(a) == "A *")
local b = packageoption_b.B()
assert(swig_type(b) == "B *")
