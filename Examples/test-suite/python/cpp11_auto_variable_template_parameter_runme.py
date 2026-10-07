from cpp11_auto_variable_template_parameter import *
from swig_test_utils import swig_check

swig_check(IntParm3.value, 3)
swig_check(ConstShortParm4.value, 4)
swig_check(TypeParmDouble.zero, 0.0)
swig_check(TypeParmDouble.three, 3.0)
swig_check(TypeParmDouble().made(), 0.0)
swig_check(TypeParmConstShort.zero, 0)
swig_check(TypeParmConstShort.three, 3)
swig_check(TypeParmDouble.four, 4.0)
swig_check(TypeParmConstShort.four, 4)
