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

# fwd class declaration
check(17, o.byval1fwdptr(x))
check(18, o.byval1fwdptr(None))

check(19, o.byval2fwdptr(None))
check(20, o.byval2fwdptr(x))

check(21, o.byval1fwdref(x))

check(22, o.byval2fwdref(x))

check(23, o.bychar1("a"))
check(24, o.bychar1(None))

# NULL is a NULL pointer for an array of char too
check(37, o.bychararray(x))
check(-38, o.bychararray(None))
check(38, o.bychararray("ab"))

check(39, o.byunsizedchararray(x))
check(-40, o.byunsizedchararray(None))
check(40, o.byunsizedchararray("ab"))
