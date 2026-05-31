local v=require("global_ns_arg")

local a = v.foo(2)
assert(a == 2)
local b = v.bar_fn()
assert(b == 1)
