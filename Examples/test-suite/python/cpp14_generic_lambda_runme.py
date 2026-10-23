from cpp14_generic_lambda import *

from swig_test_utils import swig_check

# Single auto parameter.
swig_check(run_twice(5), 10)

# Two auto parameters.
swig_check(run_add(3, 4), 7)

# 'auto' placeholder as the explicit trailing return type.
swig_check(run_negate_value(5), -5)
swig_check(run_halve(9), 4)
swig_check(run_quarter(9), 2)
swig_check(run_reference_thing(), 7)
swig_check(run_address_of_thing(), 7)
