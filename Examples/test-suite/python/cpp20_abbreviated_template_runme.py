from cpp20_abbreviated_template import *
import cpp20_abbreviated_template as _mod

from swig_test_utils import swig_assert, swig_assert_raises, swig_check

# Single auto parameter.
swig_check(twice_int(5), 10)
swig_check(twice_short(7), 14)

# Two auto parameters with mixed types (int * double => double).
swig_check(scale_id(3, 2.5), 7.5)

# Three auto parameters.
swig_check(sum3_iii(1, 2, 3), 6)

# Unnamed auto parameter.
swig_check(unnamed_auto_int(99), 42)

# Constrained auto.
swig_check(twice_numeric_int(7), 14)

# Mixed type-constraints.
swig_check(scale_mixed_id(3, 2.5), 7.5)

# Same type-constraint on multiple parms.
swig_check(add_same_int(4, 5), 9)

# Unnamed constrained auto.
swig_check(unnamed_constrained_int(99), 42)

# Constrained auto return type with explicit trailing return type.
swig_check(half(10), 5)
swig_check(cube_constrained_int(3), 27)

# Plain auto return type + constrained auto parameter + trailing return type.
swig_check(twice_n_arrow_int(7), 14)

# A decltype in the trailing return type names the parameter, so the %template argument gives the return type.
swig_check(shadow_placeholder_double(2.5), 2.5)
swig_check(second_placeholder_id(1, 2.5), 2.5)
swig_check(constrained_arrow_double(1.25), 2.5)

# Auto parameter pack - one wrapped parameter per type given to %template.
swig_check(sum_all_ii(1, 2), 3)
swig_check(sum_all_iii(1, 2, 3), 6)
swig_check(sum_numeric_ii(4, 5), 9)

# Ordinary parameter ahead of an auto parameter pack.
swig_check(offset_sum_ii(1, 2, 3), 6)

# An auto parameter pack followed by another auto parameter, and two auto parameter packs.
swig_check(pack_then_one_iii(1, 2, 3), 6)
swig_check(two_packs_ii(4, 5), 9)
swig_check(pack_then_two_iiii(1, 2, 3, 4), 10)

# A pack followed by a plain parameter, which invents no template parameter of its own.
swig_check(pack_then_plain_ii(1, 2, 7), 207)
swig_check(pack_then_plain_numeric_ii(1, 2, 5.0), 205)

# The size of each pack, which a wrong partition between them changes.  Explicitly written template
# arguments all go to the first pack, so the second is empty however many arguments are given.
swig_check(count_two_packs_ii(1, 2), 200)
swig_check(count_two_packs_iii(1, 2, 3), 300)
swig_check(count_two_packs_renamed(1, 2, 3, 4), 400)
swig_check(count_pack_then_one_iii(1, 2, 3), 203)
swig_check(count_trailing_pack_ii(1, 2, 3), 102)

# The same shapes with more than one type.  A type in the wrong position changes the result,
# because only the pack members are doubled.
swig_check(mixed_pack_then_one_ddi(1.5, 2.5, 3), 11)
swig_check(mixed_pack_then_one_idd(1, 2.5, 3.5), 10)
swig_check(mixed_trailing_pack_idd(1, 2.5, 3.5), 13)
swig_check(mixed_trailing_pack_did(1.5, 2, 3.5), 12)
swig_check(pack_then_two_ddii(1.5, 2.5, 3, 4), 11)
swig_check(two_packs_id(4, 5.5), 9)
swig_check(offset_sum_id(1, 2, 3.5), 6)
swig_check(sum_numeric_id(1, 2.5), 3)

# Undecorated auto parameter pack.
swig_check(sum_bare_ii(1, 2), 3)
swig_check(sum_bare_iii(1, 2, 3), 6)
swig_check(unnamed_bare_ii(7, 8), 42)

# The pack determines the arity of the wrapper.
with swig_assert_raises(TypeError):
    sum_all_ii(1, 2, 3)
with swig_assert_raises(TypeError):
    sum_all_iii(1, 2)

# An 'auto&&' pack wraps as pointer parms in Python, like any other 'auto&&' parm.
swig_assert(sum_fwd_ii is not None, "sum_fwd_ii")

# Constrained 'Numeric auto' return without a trailing return type - SWIG cannot deduce so the function is ignored.
swig_assert(not hasattr(_mod, "half_numeric"), "half_numeric should be ignored (deduced return type)")

# An abbreviated constructor template, instantiated in %extend.
swig_check(AbbrevCtor(5).value, 5)
swig_check(AbbrevCtor(AbbrevTag()).value, 3)
swig_check(AbbrevCtorExplicit(2.5).value, 2)
swig_check(AbbrevCtorConstrained(7).value, 7)
# -builtin raises TypeError rather than AttributeError for a class with no constructor.
with swig_assert_raises((AttributeError, TypeError)):
    AbbrevCtorNone(1)
