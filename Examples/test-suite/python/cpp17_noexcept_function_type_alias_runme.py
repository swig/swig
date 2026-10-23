from cpp17_noexcept_function_type_alias import *

from swig_test_utils import swig_check

swig_check(call_alt_noexcept(get_alt_noexcept_callback(), 7), 14)
swig_check(call_alt_noexcept_fn(get_alt_noexcept_callback(), 7), 14)
swig_check(call_alt_noexcept_expr(get_alt_noexcept_callback(), 7), 14)
