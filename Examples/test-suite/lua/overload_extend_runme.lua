require("overload_extend")

local f = overload_extend.Foo()
assert(f:test(3) == 1)
assert(f:test("hello") == 2)
assert(f:test(3.5,2.5) == 6)
