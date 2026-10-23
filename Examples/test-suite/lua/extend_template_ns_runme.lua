require("extend_template_ns")

local f = extend_template_ns.Foo_One()
assert(f:test1(37) == 37)
assert(f:test2(42) == 42)
