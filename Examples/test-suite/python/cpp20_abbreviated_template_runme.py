from cpp20_abbreviated_template import *
import cpp20_abbreviated_template as _mod

from swig_test_utils import swig_assert, swig_check

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

# Constrained 'Numeric auto' return without a trailing return type - SWIG cannot deduce so the function is ignored.
swig_assert(not hasattr(_mod, "half_numeric"), "half_numeric should be ignored (deduced return type)")
