from using_member import *

def swig_assert_equal(a, b):
	if a != b:
		raise RuntimeError(str(a) + " != " + str(b))

b = B()
swig_assert_equal(b.get(int(1)), 10)
swig_assert_equal(b.get(float(1)), 20)

bb = BB()
swig_assert_equal(bb.greater(int(1)), 0)
swig_assert_equal(bb.greater(float(1)), 1)
swig_assert_equal(bb.great(True), 2)
