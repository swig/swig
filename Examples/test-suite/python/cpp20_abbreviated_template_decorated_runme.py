from cpp20_abbreviated_template_decorated import *

from swig_test_utils import swig_check, swig_assert

# Decorated parms h (auto&), i (auto*), j (auto&&), m (Numeric auto&) wrap as SWIG pointer parms in
# Python by default, so they can't be called with a raw int.  Verify the wrappers exist instead.
swig_assert(h_dec_i is not None, "h_dec_i")
swig_assert(i_dec_i is not None, "i_dec_i")
swig_assert(j_dec_i is not None, "j_dec_i")
swig_assert(m_dec_i is not None, "m_dec_i")

# k. const auto (by value)
swig_check(k_dec_i(13), 13)

# l. const auto& (const ref to int wraps as pass by value for Python)
swig_check(l_dec_i(14), 14)

# n. const Numeric auto&
swig_check(n_dec_i(16), 16)

# o. Decorated auto mixed with explicit head.  T=std::string, auto=int.
swig_check(o_dec_si("box", 9), "box:9")

# p. auto const&
swig_check(p_dec_i(17), 17)

# q. Numeric auto const&
swig_check(q_dec_i(18), 18)

# s. Type constrained auto variables.  'const Numeric auto&' deduces 'const int &'.
swig_check(cvar.constrained_cref, 5)
cvar.constrained_global = 12
swig_check(cvar.constrained_cref, 12)
swig_assert(cvar.constrained_ref is not None, "constrained_ref")
