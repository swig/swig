from cpp20_concepts import *

def check_equal(a, b):
    if a != b:
        raise RuntimeError("{} is not equal to {}".format(a, b))

# Trailing requires-clause.
check_equal(cube_int(3), 27)
check_equal(cube_int(-4), -64)
check_equal(cube_double(2.0), 8.0)
check_equal(cube_double(0.5), 0.125)

# Prefix requires-clause - bare concept.
check_equal(quad_int(2), 16)
check_equal(quad_int(-3), 81)
check_equal(quad_double(1.5), 5.0625)

# Prefix requires-clause - compound constraint joined by '&&'.
check_equal(half_int(8), 4)
check_equal(half_int(-9), -4)

# Prefix requires-clause - parenthesised constraint subexpression.
check_equal(identity_int(42), 42)
check_equal(identity_int(-1), -1)

# Trailing requires-clause whose constraint contains a requires-expression
# as a primary.
check_equal(add_int(2, 3), 5)
check_equal(add_int(-7, 4), -3)

# Function template constrained by a named concept whose body is a requires-expression.
check_equal(sum_pair_int(2, 3), 5)
check_equal(sum_pair_int(-7, 4), -3)

# Function template constrained by a concept whose requires-expression contains
# a compound requirement '{ a + b } -> std::same_as<T>;'.
check_equal(add_same_int(2, 3), 5)
check_equal(add_same_int(-7, 4), -3)

# Inline 'requires requires' with a compound requirement.
check_equal(add_inline_same_int(2, 3), 5)
check_equal(add_inline_same_int(-7, 4), -3)

# Multiple simple-requirements.
e = Engine()
check_equal(cycle_engine(e), True)
check_equal(e.running, False)

# Type-, noexcept compound- and nested-requirements.
check_equal(check_container_c(Container()), True)
