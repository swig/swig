from swig_catch_stdexcept import *
from swig_test_utils import swig_assert_raises

with swig_assert_raises(ValueError):
    throw_invalid_argument()
with swig_assert_raises(IndexError):
    throw_out_of_range()
with swig_assert_raises(RuntimeError):
    throw_runtime_error()
with swig_assert_raises(TypeError):
    throw_bad_cast()
with swig_assert_raises(SystemError):
    throw_exception()
with swig_assert_raises(RuntimeError):
    throw_int()
