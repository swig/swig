from cpp20_abbreviated_template_overloads import *

from swig_test_utils import swig_check

# Two instantiations of one abbreviated function template sharing a name are overloads.
swig_check(scaled(3), 30)
swig_check(scaled(2.5), 25)
