require("overload_extend2")

local f = overload_extend2.Foo()
assert(f:test(3) == 1)
assert(f:test("hello") == 2)
assert(f:test(3.5,2.5) == 3)
