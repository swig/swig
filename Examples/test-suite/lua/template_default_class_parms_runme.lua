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

local second = v.Second()
second.value = 5
local defaulted = v.DefaultedSecondInt()
defaulted.third = second
assert(defaulted:copy_third().value == 5, "copy_third")
assert(v.third_value(defaulted) == 5, "third_value")
defaulted.second = 10
assert(defaulted.second == 10, "second")
