require("long_long")

assert(long_long.foo1(-1) == nil)
assert(long_long.foo2(-1) == nil)
assert(long_long.foo3(-1) == nil)
assert(long_long.foo5(-1) == nil)

assert(not pcall(function() long_long.foo4(-1) end))
assert(not pcall(function() long_long.foo6(-1) end))
