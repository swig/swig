import overload_arrays
from swig_test_utils import swig_assert, swig_check

swig_check(overload_arrays.literal_overload(7), 7)
swig_check(overload_arrays.literal_overload("abc"), ord("a"))
try:
    overload_arrays.literal_overload(1.5)
    raise RuntimeError("literal_overload did not fail")
except TypeError as e:
    swig_assert('literal_overload(char [sizeof("abc")])' in str(e), str(e))
