local v=require("cpp11_variadic_templates")

local ma = v.MultiArgs1()

-- SizeOf testing
assert(v.SizeOf0.size == 0, "v.SizeOf0.size")
assert(v.SizeOf1.size == 1, "v.SizeOf1.size")
assert(v.SizeOf2.size == 2, "v.SizeOf2.size")
assert(v.SizeOf3.size == 3, "v.SizeOf3.size")

local a = v.A()
local b = v.B()
local c = v.C()
local d = v.D()

-- MultiInherit0
local mi0 = v.MultiInherit0()
mi0:MultiInstanceMethod()
v.MultiInherit0.MultiStaticMethod()
mi0:InstanceMethod()
v.MultiInherit0.StaticMethod()

-- MultiInherit1
local mi1 = v.MultiInherit1(a)
assert(mi1.a == 100, "mi1.a")
mi1:MultiInstanceMethod(a)
v.MultiInherit1.MultiStaticMethod(a)
mi1:InstanceMethod()
v.MultiInherit1.StaticMethod()

-- MultiInherit2
local mi2 = v.MultiInherit2(a, b)
assert(mi2.a == 100, "mi2.a")
assert(mi2.b == 200, "mi2.b")
mi2:MultiInstanceMethod(a, b)
v.MultiInherit2.MultiStaticMethod(a, b)
mi2:InstanceMethod()
v.MultiInherit2.StaticMethod()

-- MultiInherit3
local mi3 = v.MultiInherit3(a, b, c)
assert(mi3.a == 100, "mi3.a")
assert(mi3.b == 200, "mi3.b")
assert(mi3.c == 300, "mi3.c")
mi3:MultiInstanceMethod(a, b, c)
v.MultiInherit3.MultiStaticMethod(a, b, c)
mi3:InstanceMethod()
v.MultiInherit3.StaticMethod()

-- NumerousInherit0
local num = 123
local ni0 = v.NumerousInherit0(num)
ni0:NumerousInstanceMethod(num)
v.NumerousInherit0.NumerousStaticMethod(num)
ni0:InstanceMethod()
v.NumerousInherit0.StaticMethod()

-- NumerousInherit1
local nil0 = v.NumerousInherit1(num, a)
assert(nil0.a == 100, "nil0.a")
nil0:NumerousInstanceMethod(num, a)
v.NumerousInherit1.NumerousStaticMethod(num, a)
nil0:InstanceMethod()
v.NumerousInherit1.StaticMethod()

-- NumerousInherit2
local ni2 = v.NumerousInherit2(num, a, b)
assert(ni2.a == 100, "ni2.a")
assert(ni2.b == 200, "ni2.b")
ni2:NumerousInstanceMethod(num, a, b)
v.NumerousInherit2.NumerousStaticMethod(num, a, b)
ni2:InstanceMethod()
v.NumerousInherit2.StaticMethod()

-- NumerousInherit3
local ni3 = v.NumerousInherit3(num, a, b, c)
assert(ni3.a == 100, "ni3.a")
assert(ni3.b == 200, "ni3.b")
assert(ni3.c == 300, "ni3.c")
ni3:NumerousInstanceMethod(num, a, b, c)
v.NumerousInherit3.NumerousStaticMethod(num, a, b, c)
ni3:InstanceMethod()
v.NumerousInherit3.StaticMethod()

-- LotsInherit1
local lots1 = v.LotsInherit1(a)
assert(lots1.a == 100, "lots1.a")
lots1:LotsInstanceMethod(a)
v.LotsInherit1.LotsStaticMethod(a)
lots1:InstanceMethod()
v.LotsInherit1.StaticMethod()

-- LotsInherit2
local lots2 = v.LotsInherit2(a, b)
assert(lots2.a == 100, "lots2.a")
assert(lots2.b == 200, "lots2.b")
lots2:LotsInstanceMethod(a, b)
v.LotsInherit2.LotsStaticMethod(a, b)
lots2:InstanceMethod()
v.LotsInherit2.StaticMethod()

-- LotsInherit3
local lots3 = v.LotsInherit3(a, b, c)
assert(lots3.a == 100, "lots3.a")
assert(lots3.b == 200, "lots3.b")
assert(lots3.c == 300, "lots3.c")
lots3:LotsInstanceMethod(a, b, c)
v.LotsInherit3.LotsStaticMethod(a, b, c)
lots3:InstanceMethod()
v.LotsInherit3.StaticMethod()

-- LotsInherit4
local lots4 = v.LotsInherit4(a, b, c, d)
assert(lots4.a == 100, "lots4.a")
assert(lots4.b == 200, "lots4.b")
assert(lots4.c == 300, "lots4.c")
assert(lots4.d == 400, "lots4.c")
lots4:LotsInstanceMethod(a, b, c, d)
v.LotsInherit4.LotsStaticMethod(a, b, c, d)
lots4:InstanceMethod()
v.LotsInherit4.StaticMethod()

-- PlainStruct
local ps = v.PlainStruct()
ps:PlainStructParms0()
ps:PlainStructParms1(a)
ps:PlainStructParms2(a, b)
ps:PlainStructParms3(a, b, c)
