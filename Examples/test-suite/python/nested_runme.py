from nested import *

def check(a, b):
    if a != b:
        raise RuntimeError("Problem: {} != {}".format(a, b))
xx = x_t()
yy = y_t()
aa = a_t()
bb = b_t()
cc = c_t()
dd = d_t()

set_union_values(100, xx, yy, aa, bb, cc, dd)

check(xx.duplicate_p.x, 100)
check(yy.duplicate_p.y, 101)
check(aa.duplicate_p.a, 102)
check(bb.duplicate_p.b, 103)
check(cc.duplicate_p.c, 104)
check(dd.duplicate_p.d, 105)
