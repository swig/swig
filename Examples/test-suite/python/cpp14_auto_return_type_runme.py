from cpp14_auto_return_type import *
from swig_test_utils import swig_check

swig_check(va_static_cast(), 42)

x = X()
swig_check(x.a(), "a string")
swig_check(x.cref(), 42)

swig_check(Deduced(7).toInt(), 7)
swig_check(DeducedPtr(8).deref(), 8)
swig_check(DeducedPtr(9).cref(), 9)

# The deleted functions with a deduced return type are not wrapped.
swig_check(hasattr(X, "deleted"), False)
swig_check("deleted_global" in globals(), False)
