from cpp20_spaceship_operator import *

def check_equal(a, b):
    if a != b:
        raise RuntimeError("{} is not equal to {}".format(a, b))

check_equal(ALIEN, 1)
check_equal(SPACE, 1)
check_equal(COMET, 1)
check_equal(cvar.v, 42)

x = A(1)
y = A(2)

check_equal(spaceship(x, y) < 0, True)
check_equal(spaceship(x, x), 0)
check_equal(spaceship(y, x) > 0, True)

check_equal(f(), 42)

# The defaulted operator<=> has a deduced return type and is ignored, the
# defaulted operator== returns bool and is wrapped.
check_equal(hasattr(Defaulted, "spaceship"), False)
check_equal(Defaulted(1).is_equal(Defaulted(1)), True)
check_equal(Defaulted(1).is_equal(Defaulted(2)), False)

# Deleted functions with a deduced return type are ignored.
check_equal(hasattr(Deleted, "spaceship"), False)
check_equal(hasattr(Deleted, "m"), False)
