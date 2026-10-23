from cpp20_concepts_class_methods import *


def check_equal(a, b):
    if a != b:
        raise RuntimeError("{} is not equal to {}".format(a, b))


c = Calculator()

# Trailing requires-clause on a member function template.
check_equal(c.cube_int(3), 27)
check_equal(c.cube_int(-4), -64)
check_equal(c.cube_double(2.0), 8.0)

# Prefix requires-clause on a member function template.
check_equal(c.quad_int(2), 16)
check_equal(c.quad_int(-3), 81)

# Static member function template constrained by an inline requires-expression.
check_equal(Calculator.sum_int(2, 3), 5)
check_equal(Calculator.sum_int(-7, 4), -3)

# Member function template constrained by a named concept whose body is itself a requires-expression.
check_equal(c.addn_int(7, 4), 11)
check_equal(c.addn_int(-2, 5), 3)

# Member function template with two template parameters and a compound constraint joined by '&&'.
check_equal(c.scale_int_int(5, 3), 15)
check_equal(c.scale_int_int(-4, 2), -8)
