from cpp11_rvalue_reference3 import *
from swig_test_utils import swig_check, swig_assert_raises

swig_check(funcref_takeit1(FUNCREF_DOUBLE, 3), 6)
swig_check(funcref_takeit2(FUNCREF_DOUBLE, 4), 8)
swig_check(funcref_takeit1(funcref_returnit1(), 5), 10)
swig_check(funcref_takeit2(funcref_returnit2(), 6), 12)
with swig_assert_raises(TypeError):
    funcref_takeit1(None, 1)
