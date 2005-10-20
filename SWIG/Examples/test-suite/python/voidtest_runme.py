import voidtest

voidtest.globalfunc()
f = voidtest.Foo()
f.memberfunc()

voidtest.Foo_staticmemberfunc()

def fvoid():
    pass

if  f.memberfunc() != fvoid():
    raise RuntimeError
