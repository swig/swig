from overload_kwargs_builtin import bfoo
from swig_test_utils import *

# Positional dispatch still works in -builtin mode.
swig_assert(bfoo(3) == 3)
swig_assert(bfoo(1, 2) == 3)

# Keyword arguments are not supported with overloads in -builtin mode.
with swig_assert_raises(TypeError):
    bfoo(x=3)
