from li_typemaps import *
from swig_test_utils import swig_assert_raises, swig_check

swig_check(in_int(7), 7)
swig_check(inr_int(7), 7)
swig_check(out_int(7), 7)
swig_check(inout_int(7), 7)
swig_check(inoutr_int(7), 7)

# Two parameters using the same typemap
swig_check(in_int_multi(3, 4), 7)
swig_check(out_int_multi(5, 6), [5, 6])
swig_check(inout_int_multi(7, 8), [14, 24])

# A reference cannot be bound to a null pointer, so None is rejected rather than dereferenced in the call
with swig_assert_raises(TypeError):
    inr_int(None)
with swig_assert_raises(TypeError):
    inoutr_int(None)
