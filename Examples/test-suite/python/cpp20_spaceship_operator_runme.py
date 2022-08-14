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
