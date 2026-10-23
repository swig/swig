from using_member_typedef_template import *

from swig_test_utils import swig_check


# Each class member and each global function takes an Integer (a typedef chain
# resolving to int) and returns it unchanged, so check the value survives.

a = UsingDerivedA()
swig_check(a.aa(11), 11)

b = UsingDerivedB()
swig_check(b.bb(21), 21)
swig_check(b.bbb(22), 22)

c = UsingDerivedC()
swig_check(c.cc(31), 31)
swig_check(c.ccc(32), 32)

d = UsingDerivedD()
swig_check(d.dd(41), 41)
swig_check(d.ddd(42), 42)

e = UsingDerivedE()
swig_check(e.ee(51), 51)
swig_check(e.eee(52), 52)

f = UsingDerivedF()
swig_check(f.ff(61), 61)
swig_check(f.fff(62), 62)

g = UsingDerivedG()
swig_check(g.gg(71), 71)
swig_check(g.ggg(72), 72)

h = UsingDerivedH()
swig_check(h.hh(81), 81)
swig_check(h.hhh(82), 82)

i = UsingDerivedI()
swig_check(i.ii(91), 91)
swig_check(i.iii(92), 92)

swig_check(a_tester(1), 1)
swig_check(b_tester(2), 2)
swig_check(c_tester(3), 3)
swig_check(d_tester(4), 4)
swig_check(e_tester(5), 5)
swig_check(f_tester(6), 6)
swig_check(g_tester(7), 7)
swig_check(h_tester(8), 8)
swig_check(i_tester(9), 9)
