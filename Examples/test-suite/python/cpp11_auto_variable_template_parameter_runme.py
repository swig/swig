from cpp11_auto_variable_template_parameter import *
from swig_test_utils import swig_check

swig_check(IntParm3.value, 3)
swig_check(ConstShortParm4.value, 4)
