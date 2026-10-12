import arrays_null
from swig_test_utils import swig_check, swig_assert_raises

s = arrays_null.ArraysNull()
other = arrays_null.ArraysNull()
arrays_null.arrays_null_fill(other, 10)
s.ints = other.ints
s.items = other.items
s.grid = other.grid
swig_check(arrays_null.arrays_null_check(s, 10), 1)

# Setting an array member or global variable to None is an error, as there is nothing to copy from.
with swig_assert_raises(TypeError):
    s.ints = None
with swig_assert_raises(TypeError):
    s.items = None
with swig_assert_raises(TypeError):
    s.grid = None
swig_check(arrays_null.arrays_null_check(s, 10), 1)

arrays_null.cvar.arrays_null_ints = s.ints
arrays_null.cvar.arrays_null_items = s.items
arrays_null.cvar.arrays_null_grid = s.grid
swig_check(arrays_null.arrays_null_globals_check(10), 1)

with swig_assert_raises(TypeError):
    arrays_null.cvar.arrays_null_ints = None
with swig_assert_raises(TypeError):
    arrays_null.cvar.arrays_null_items = None
with swig_assert_raises(TypeError):
    arrays_null.cvar.arrays_null_grid = None
with swig_assert_raises(TypeError):
    arrays_null.cvar.arrays_null_ints_ref = None
swig_check(arrays_null.arrays_null_globals_check(10), 1)

# None is passed on as a NULL pointer for an array parameter.
swig_check(arrays_null.arrays_null_isnull(None), 1)
