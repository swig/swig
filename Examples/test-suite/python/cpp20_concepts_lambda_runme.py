from cpp20_concepts_lambda import *

from swig_test_utils import swig_check

# Trailing requires-clause - bare concept.
swig_check(run_trailing(5), 10)

# Trailing requires-clause - compound '&&'.
swig_check(run_compound(7), 14)

# Trailing requires-clause - inline 'requires requires'.
swig_check(run_inline_req(2, 3), 5)

# 'mutable' followed by trailing requires-clause.
swig_check(run_with_mut(4), 8)

# Prefix requires-clause on a templated lambda.
swig_check(run_prefix(5), 10)

# Prefix requires-clause on a templated lambda with no parameter list.
swig_check(run_prefix_no_parms(), 7)

# Trailing return type combined with a trailing requires-clause.
swig_check(run_with_ret(6), 12)

# Both prefix and trailing requires-clauses on the same lambda.
swig_check(run_both_clauses(3), 6)

# Constrained auto parameter lambda - the 'Numeric auto' form.
swig_check(run_auto_param(8), 16)
