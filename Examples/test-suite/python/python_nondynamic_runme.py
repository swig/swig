import python_nondynamic

aa = python_nondynamic.A()

aa.a = 1
aa.b = 2

assert(aa.a == 1)
assert(aa.b == 2)

# Sanity check to see if all the funky setattr methods make it into C.
if hasattr(python_nondynamic._python_nondynamic, "A_a_get"):
    # -builtin was not used.
    assert(python_nondynamic._python_nondynamic.A_a_get(aa) == 1)
    assert(python_nondynamic._python_nondynamic.A_b_get(aa) == 2)
    

try:
    aa.c = 2
    err = 0
except:
    err = 1

if not err:
    raise RuntimeError, "A is not static"


class B(python_nondynamic.A):
    c = 4

    def __init__(self):
        python_nondynamic.A.__init__(self)
        pass
    pass

bb = B()
bb.a = 4
bb.b = 5
assert(bb.a == 4)
assert(bb.b == 5)


try:
    bb.c = 3
    err = 0
except:
    err = 1

if not err:
    print "bb.c = %d" % bb.c
    print "B.c = %d" % B.c
    raise RuntimeError, "B.c class variable messes up nondynamic-ness of B"

try:
    bb.d = 2
    err = 0
except:
    err = 1

if not err:
    raise RuntimeError, "B is not static"

cc = python_nondynamic.C()
cc.d = 3
