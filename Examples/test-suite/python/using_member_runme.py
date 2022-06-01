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

cc = CC()
swig_assert_equal(cc.greater(int(10)), 0)
swig_assert_equal(cc.greater(float(10)), 1)
swig_assert_equal(cc.greater(True), 20)

dd = DD()
swig_assert_equal(dd.greater(int(10)), 0)
swig_assert_equal(dd.greater(float(10)), 1)
swig_assert_equal(dd.greaterstill(True), 30)
