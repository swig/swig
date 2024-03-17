from cpp11_variadic_templates import *

ma = MultiArgs1()

# SizeOf testing
so0 = SizeOf0()
if so0.size != 0:
    raise RuntimeError("so0.size")
so1 = SizeOf1()
if so1.size != 1:
    raise RuntimeError("so1.size")
so2 = SizeOf2()
if so2.size != 2:
    raise RuntimeError("so2.size")
so3 = SizeOf3()
if so3.size != 3:
    raise RuntimeError("so3.size")

a = A()
b = B()
c = C()
d = D()

# MultiInherit0
mi0 = MultiInherit0()
mi0.MultiInstanceMethod()
MultiInherit0.MultiStaticMethod()
mi0.InstanceMethod()
MultiInherit0.StaticMethod()

# MultiInherit1
mi1 = MultiInherit1(a)
if mi1.a != 100:
    raise RuntimeError("fail mi1.a")
mi1.MultiInstanceMethod(a)
MultiInherit1.MultiStaticMethod(a)
mi1.InstanceMethod()
MultiInherit1.StaticMethod()

# MultiInherit2
mi2 = MultiInherit2(a, b)
if mi2.a != 100:
    raise RuntimeError("fail mi2.a")
if mi2.b != 200:
    raise RuntimeError("fail mi2.b")
mi2.MultiInstanceMethod(a, b)
MultiInherit2.MultiStaticMethod(a, b)
mi2.InstanceMethod()
MultiInherit2.StaticMethod()

# MultiInherit3
mi3 = MultiInherit3(a, b, c)
if mi3.a != 100:
    raise RuntimeError("fail mi3.a")
if mi3.b != 200:
    raise RuntimeError("fail mi3.b")
if mi3.c != 300:
    raise RuntimeError("fail mi3.c")
mi3.MultiInstanceMethod(a, b, c)
MultiInherit3.MultiStaticMethod(a, b, c)
mi3.InstanceMethod()
MultiInherit3.StaticMethod()

# NumerousInherit0
num = 123
ni0 = NumerousInherit0(num)
ni0.NumerousInstanceMethod(num)
NumerousInherit0.NumerousStaticMethod(num)
ni0.InstanceMethod()
NumerousInherit0.StaticMethod()

# NumerousInherit1
ni1 = NumerousInherit1(num, a)
if ni1.a != 100:
    raise RuntimeError("fail ni1.a")
ni1.NumerousInstanceMethod(num, a)
NumerousInherit1.NumerousStaticMethod(num, a)
ni1.InstanceMethod()
NumerousInherit1.StaticMethod()

# NumerousInherit2
ni2 = NumerousInherit2(num, a, b)
if ni2.a != 100:
    raise RuntimeError("fail ni2.a")
if ni2.b != 200:
    raise RuntimeError("fail ni2.b")
ni2.NumerousInstanceMethod(num, a, b)
NumerousInherit2.NumerousStaticMethod(num, a, b)
ni2.InstanceMethod()
NumerousInherit2.StaticMethod()

# NumerousInherit3
ni3 = NumerousInherit3(num, a, b, c)
if ni3.a != 100:
    raise RuntimeError("fail ni3.a")
if ni3.b != 200:
    raise RuntimeError("fail ni3.b")
if ni3.c != 300:
    raise RuntimeError("fail ni3.c")
ni3.NumerousInstanceMethod(num, a, b, c)
NumerousInherit3.NumerousStaticMethod(num, a, b, c)
ni3.InstanceMethod()
NumerousInherit3.StaticMethod()

LotsInherit1
lots1 = LotsInherit1(a)
if lots1.a != 100:
    raise RuntimeError("fail lots1.a")
lots1.LotsInstanceMethod(a)
LotsInherit1.LotsStaticMethod(a)
lots1.InstanceMethod()
LotsInherit1.StaticMethod()

# LotsInherit2
lots2 = LotsInherit2(a, b)
if lots2.a != 100:
    raise RuntimeError("fail lots2.a")
if lots2.b != 200:
    raise RuntimeError("fail lots2.b")
lots2.LotsInstanceMethod(a, b)
LotsInherit2.LotsStaticMethod(a, b)
lots2.InstanceMethod()
LotsInherit2.StaticMethod()

# LotsInherit3
lots3 = LotsInherit3(a, b, c)
if lots3.a != 100:
    raise RuntimeError("fail lots3.a")
if lots3.b != 200:
    raise RuntimeError("fail lots3.b")
if lots3.c != 300:
    raise RuntimeError("fail lots3.c")
lots3.LotsInstanceMethod(a, b, c)
LotsInherit3.LotsStaticMethod(a, b, c)
lots3.InstanceMethod()
LotsInherit3.StaticMethod()

# LotsInherit4
lots4 = LotsInherit4(a, b, c, d)
if lots4.a != 100:
    raise RuntimeError("fail lots4.a")
if lots4.b != 200:
    raise RuntimeError("fail lots4.b")
if lots4.c != 300:
    raise RuntimeError("fail lots4.c")
if lots4.d != 400:
    raise RuntimeError("fail lots4.c")
lots4.LotsInstanceMethod(a, b, c, d)
LotsInherit4.LotsStaticMethod(a, b, c, d)
lots4.InstanceMethod()
LotsInherit4.StaticMethod()

# PlainStruct
ps = PlainStruct()
ps.PlainStructParms0()
ps.PlainStructParms1(a)
ps.PlainStructParms2(a, b)
ps.PlainStructParms3(a, b, c)
