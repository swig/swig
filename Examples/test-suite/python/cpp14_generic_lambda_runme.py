from cpp14_generic_lambda import *

from swig_test_utils import swig_check

# Single auto parameter.
swig_check(run_twice(5), 10)

# Two auto parameters.
swig_check(run_add(3, 4), 7)
