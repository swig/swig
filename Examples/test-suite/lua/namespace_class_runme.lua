local v=require("namespace_class")

v.EulerT3D.toFrame(1, 1, 1)
local b = v.BooT_i()
b = v.BooT_H()

local f = v.FooT_i()
f:quack(1)
f = v.FooT_d()
f:moo(1)
f = v.FooT_H()
f:foo(v.Hi)
assert(swig_type(f) == "test::hola::FooT< test::Hello > *|test::hola::FooT< enum test::Hello > *")
