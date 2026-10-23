from using_member_typedef_overload import *
from swig_test_utils import swig_check

# Overload imported through the typedef-to-template-instantiation qualifier merges with the local one.
c = CalcInt()
swig_check(c.add(5), 105)     # local single-arg overload
swig_check(c.add(2, 3), 5)    # imported two-arg overload via using through the typedef

# Unscoped enum inherited via a using-declaration whose qualifier is a typedef for the base; the
# enumerators wrap as attributes of the Colours proxy, and the typedef names a function parameter.
swig_check(Colours.RED, 0)
swig_check(Colours.GREEN, 1)
swig_check(Colours.BLUE, 2)
swig_check(to_int(Colours.GREEN), 1)
swig_check(to_int(Colours.BLUE), 2)
