local v=require("overload_polymorphic")

local t = v.Derived()
assert(v.test(t), 0, "test(Derived)")
assert(v.test(1), 1, "test(1)")
assert(v.test2(t), 1, "test2(Derived)")
assert(v.test3(t, nil, t), 1, "test3(Derived, nil, Derived)")
