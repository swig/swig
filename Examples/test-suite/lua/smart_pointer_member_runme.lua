local v=require("smart_pointer_member")

local f = v.Foo()
f.y = 1
assert(f.y == 1)

b = v.Bar(f)
b.y = 2
assert(f.y == 2)
assert(swig_equals(b.x, f.x))
assert(b.z == v.Foo.z)
assert(swig_equals(b:__deref__(), f))
