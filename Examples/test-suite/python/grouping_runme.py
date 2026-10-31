import grouping
from swig_test_utils import swig_check

x = grouping.test1(42)
if x != 42:
    raise RuntimeError

grouping.test2(42)

x = grouping.do_unary(37, grouping.NEGATE)
if x != -37:
    raise RuntimeError

grouping.cvar.test3 = 42
grouping.test3 = 42

swig_check(grouping.test4(42).value, 42)
swig_check(grouping.test5(), 37)
swig_check(grouping.test5(42), 42)
swig_check(grouping.test6(42), 42)

g = grouping.MemberGrouping()
swig_check(g.method1(42), 42)
swig_check(grouping.MemberGrouping.method2(42), 42)
swig_check(g.method3(), 37)
swig_check(g.method3(42), 42)
