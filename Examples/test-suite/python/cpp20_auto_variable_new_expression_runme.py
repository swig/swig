from cpp20_auto_variable_new_expression import *

from swig_test_utils import swig_assert, swig_check

swig_check(int_at(cvar.deduced_bound, 2), 32)
swig_check(int_value(cvar.constrained_pointer), 33)
swig_check(int_value(cvar.constrained_decorated), 34)
swig_assert(not hasattr(cvar, "constrained_allocation"), "constrained_allocation should be ignored")
