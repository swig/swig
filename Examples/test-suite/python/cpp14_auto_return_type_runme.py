from cpp14_auto_return_type import *
from swig_test_utils import swig_check

swig_check(va_static_cast(), 42)

x = X()
swig_check(x.a(), "a string")
swig_check(x.cref(), 42)
