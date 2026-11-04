from template_function_overload_kind import *

from swig_test_utils import swig_check

swig_check(kind_int(), 1)
swig_check(kind_real(), 1)
swig_check(kind_5(), 2)
swig_check(kind_constant(), 2)
swig_check(kind_red(), 2)
swig_check(kind_int_double(), 3)
swig_check(kind_box(), 4)

swig_check(kindp_double(1.5), 1.5)
swig_check(kindp_10(1), 11)

swig_check(kindsize_3(), 3)
swig_check(kindvalue_int_7(), 7)

m = KindMember()
swig_check(m.get_int(), 1)
swig_check(m.get_7(), 2)
