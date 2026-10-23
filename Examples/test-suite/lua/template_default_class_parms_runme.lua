local v=require("template_default_class_parms")

local bar = v.DefaultBar(20.0, v.SomeType(), 10)
local d = bar.CType
bar.CType = d
local s = bar.DType
bar.DType = s
local i = bar.EType
bar.EType = i
d = bar:method(d, s, i)

local foo = v.DefaultFoo(v.SomeType())
s = foo.TType
s = foo:method(s)

bar = v.BarAnotherTypeBool(v.AnotherType(), true, 10)
local a = bar.CType
bar.CType = a
local b = bar.DType
bar.DType = b
i = bar.EType
bar.EType = i
a = bar:method(a, b, i)

foo = v.FooAnotherType(v.AnotherType())
a = foo.TType
foo.TType = a
a = foo:method(a)
