from cpp20_abbreviated_template_overloads import *

from swig_test_utils import swig_check

# Two instantiations of one abbreviated function template sharing a name are overloads.
swig_check(scaled(3), 30)
swig_check(scaled(2.5), 25)

# %ignore on the Integral overload leaves the FloatingPoint one, which halves rather than increments.
swig_check(classify_double(5.0), 2.5)

# %ignore on the FloatingPoint overload leaves the Integral one.
swig_check(pick_int(5), 6)
