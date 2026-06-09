from using_nested_member_typedef import *

from swig_test_utils import swig_check

d = UsingDerived()
swig_check(d.hh(81), 81)

deep = UsingDerivedDeep()
swig_check(deep.jj(81), 81)
