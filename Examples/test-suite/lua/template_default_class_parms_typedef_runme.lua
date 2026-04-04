local v=require("template_default_class_parms_typedef")

local bar = v.DefaultBar(20, v.SomeType(), 10)
local d = bar.CType
bar.CType = d
local s = bar.DType
bar.DType = s
local i = bar.EType
bar.EType = i
d = bar:method(d, s, i)
d = bar:method_1(d, s, i)
d = bar:method_2(d, s, i)
d = bar:method_3(d, s, i)

bar = v.DefaultBar(true, 20, v.SomeType(), 10)
bar = v.DefaultBar(true, true, 20, v.SomeType(), 10)
bar = v.DefaultBar(true, true, true, 20, v.SomeType(), 10)

local foo = v.DefaultFoo(v.SomeType())
s = foo.TType
s = foo:method(s)
s = foo:method_A(s)
s = foo:method_B(s)
s = foo:method_C(s)

foo = v.DefaultFoo(v.SomeType(), v.SomeType())
foo = v.DefaultFoo(v.SomeType(), v.SomeType(), v.SomeType())
foo = v.DefaultFoo(v.SomeType(), v.SomeType(), v.SomeType(), v.SomeType())

bar = v.BarAnotherTypeBool(v.AnotherType(), true, 10)
local a = bar.CType
bar.CType = a
local b = bar.DType
bar.DType = b
i = bar.EType
bar.EType = i

a = bar:method(a, b, i)
a = bar:method_1(a, b, i)
a = bar:method_2(a, b, i)
a = bar:method_3(a, b, i)

bar = v.BarAnotherTypeBool(true, v.AnotherType(), true, 10)
bar = v.BarAnotherTypeBool(true, true, v.AnotherType(), true, 10)
bar = v.BarAnotherTypeBool(true, true, true, v.AnotherType(), true, 10)

foo = v.FooAnotherType(v.AnotherType())
a = foo.TType
foo.TType = a
a = foo:method(a)
a = foo:method_A(a)
a = foo:method_B(a)
a = foo:method_C(a)

foo = v.FooAnotherType(v.AnotherType(), v.AnotherType())
foo = v.FooAnotherType(v.AnotherType(), v.AnotherType(), v.AnotherType())
foo = v.FooAnotherType(v.AnotherType(), v.AnotherType(), v.AnotherType(), v.AnotherType())

local u = v.UsesBarDouble()
u:use_A(10.1, v.SomeType(), 10)
u:use_B(10.1, v.SomeType(), 10)
u:use_C(10.1, v.SomeType(), 10)
u:use_D(10.1, v.SomeType(), 10)
