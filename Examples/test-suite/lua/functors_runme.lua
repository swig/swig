require("functors")

local a = functors.Functor0(10)
local b = functors.Functor1(10)
local c = functors.Functor2(10)

assert(a() == -10, "a")
assert(b(1) == 11, "b")
assert(c(1, 2) == 13, "c")
