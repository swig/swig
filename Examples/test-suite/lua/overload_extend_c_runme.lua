require("overload_extend_c")

local f = overload_extend_c.Foo()
assert(f:test(3) == 1)
assert(f:test("hello") == 2)
assert(f:test(3.5,2.5) == 6)
