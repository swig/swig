import voidtest

voidtest.globalfunc()
voidtest.globalfunc_typedef()
f = voidtest.Foo()
f.memberfunc()

voidtest.Foo.staticmemberfunc()

voidtest.globalfunc_renamed()
f.memberfunc_renamed()
voidtest.Foo.staticmemberfunc_renamed()

fv = voidtest.FooVoidTypedef()
fv.memberfunc()
fv.memberfunc_const()
fv.memberfunc_const_voidptr()

voidtest.FooVoidTypedef.staticmemberfunc()

def fvoid():
    pass

if f.memberfunc() != fvoid():
    raise RuntimeError


v1 = voidtest.vfunc1(f)
v2 = voidtest.vfunc2(f)
if v1 != v2:
    raise RuntimeError

v3 = voidtest.vfunc3(v1)
if v3.this != f.this:
    raise RuntimeError
v4 = voidtest.vfunc1(f)
if v4 != v1:
    raise RuntimeError
if voidtest.vfunc_const(v1) != v1:
    raise RuntimeError


v3.memberfunc()
