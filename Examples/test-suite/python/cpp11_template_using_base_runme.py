from swig_test_utils import swig_check
import cpp11_template_using_base as m

d = m.DerivedInt()
swig_check(d.call(7), "Int:7")

# Inheriting constructor: using I::I; brings IntCase(int) into DerivedInt
d10 = m.DerivedInt(10)
swig_check(d10.call(7), "Int:17")

o = m.OverloadedIntDouble()
swig_check(o.call(7), "Int:7")
swig_check(o.call(7.5), "Double:7.500000")
