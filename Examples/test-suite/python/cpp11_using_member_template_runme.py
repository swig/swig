from swig_test_utils import swig_assert, swig_check
import cpp11_using_member_template as m

d = m.Derived()
swig_check(d.value(), 1)

md = m.MoreDerived()
swig_check(md.value(), 2)
swig_assert(isinstance(md, m.Derived))
swig_assert(isinstance(md, m.Base))
