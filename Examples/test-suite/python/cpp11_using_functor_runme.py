from cpp11_using_functor import *

from swig_test_utils import swig_check

# Overloaded helper built from two concrete functor base classes (C++11 form).
# operator() is renamed to call() by %rename, giving an overloaded proxy method.
ov = OverloadedIntDouble()
swig_check(ov.call(7), "Int:7")
swig_check(ov.call(2.5), "Double:2.500000")
