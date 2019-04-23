from overload_null import *

def check(a, b):
    if a != b:
        raise RuntimeError(str(a) + " does not equal " + str(b))

o = Overload()
x = X()

check(1, o.byval1(x))
check(2, o.byval1(None))

check(3, o.byval2(None))
check(4, o.byval2(x))

check(5, o.byref1(x))
check(6, o.byref1(None))

check(7, o.byref2(None))
check(8, o.byref2(x))

check(9, o.byconstref1(x))
check(10, o.byconstref1(None))

check(11, o.byconstref2(None))
check(12, o.byconstref2(x))

# const pointer references
check(13, o.byval1cpr(x))
check(14, o.byval1cpr(None))

check(15, o.byval2cpr(None))
check(16, o.byval2cpr(x))

# forward class declaration
check(17, o.byval1forwardptr(x))
check(18, o.byval1forwardptr(None))

check(19, o.byval2forwardptr(None))
check(20, o.byval2forwardptr(x))

check(21, o.byval1forwardref(x))

check(22, o.byval2forwardref(x))
