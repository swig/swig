from typemap_template_typedef import *

def check(got, expected):
    if got != expected:
        raise RuntimeError("got: " + str(got) + " expected: " + str(expected))

x = XXXInt()

check(x.aa1(0), 0)
check(x.aa2(0), 55)
check(x.aa3(0), 0)
check(aa1(0), 0)
check(aa2(0), 0)

check(x.bb1(0), 0)
check(x.bb2(0), 66)
check(x.bb3(0), 0)
check(bb1(0), 0)
check(bb2(0), 0)

check(x.cc1(0), 0)
check(x.cc2(0), 77)
check(x.cc3(0), 77)
check(cc1(0), 0)
check(cc2(0), 0)

check(x.dd1(0), 0)
check(x.dd2(0), 88)
check(x.dd3(0), 0)
check(dd1(0), 0)
check(dd2(0), 0)

