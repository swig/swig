local v=require("kwargs_feature")

-- Check normal overloading still works (no compactdefaultargs)
-- if the kwargs feature is used, as the kwargs feature is not supported
local f = v.Foo(99)
assert(f:foo() == 1)
assert(f:foo(3) == 3)
assert(f:foo(4, 7) == 11)
assert(v.Foo.statfoo() == 1)
assert(v.Foo.statfoo(2) == 2)
assert(v.Foo.statfoo(3, 5) == 8)
