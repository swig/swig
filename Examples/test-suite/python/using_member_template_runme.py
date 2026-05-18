from swig_test_utils import swig_assert
import using_member_template as m

d = m.Derived()
swig_assert(isinstance(d, m.Base))

md = m.MoreDerived()
swig_assert(isinstance(md, m.Derived))
swig_assert(isinstance(md, m.Base))
