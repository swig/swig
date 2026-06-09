from cpp20_abbreviated_template_decorated import *

from swig_test_utils import swig_check

# Decorated parms h (auto&), i (auto*), j (auto&&), m (Numeric auto&) wrap as SWIG pointer parms in
# Python by default, so they can't be called with a raw int.  Verify the wrappers exist instead.
assert h_dec_i is not None
assert i_dec_i is not None
assert j_dec_i is not None
assert m_dec_i is not None

# k. const auto (by value)
swig_check(k_dec_i(13), 13)

# l. const auto& (const ref to int wraps as pass by value for Python)
swig_check(l_dec_i(14), 14)

# n. const Numeric auto&
swig_check(n_dec_i(16), 16)

# o. Decorated auto mixed with explicit head.  T=std::string, auto=int.
swig_check(o_dec_si("box", 9), "box:9")
