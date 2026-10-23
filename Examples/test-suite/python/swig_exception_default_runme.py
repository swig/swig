from swig_exception_default import *
from swig_test_utils import swig_check, swig_assert_raises

swig_check(positive_only(1), 1)
with swig_assert_raises(ValueError):
    positive_only(0)

swig_check(positive_result(1), 1)
with swig_assert_raises(ValueError):
    positive_result(0)
