from cpp11_auto_variable import *

from swig_test_utils import swig_check, swig_assert

# A named cast deduces the type it casts to.
swig_check(cvar.cast_double, 1.0)
swig_assert(isinstance(cvar.cast_double, float), "cast_double should be a float")
swig_check(cvar.cast_uint, 1)
swig_assert(isinstance(cvar.cast_uint, int), "cast_uint should be an int")
swig_check(cvar.cast_constcharptr, "abc")
cvar.cast_constcharptr = "xyz"
swig_check(cvar.cast_constcharptr, "xyz")

# The address of a variable in scope deduces to a pointer to it.
swig_assert(cvar.ptr_t is not None, "ptr_t")
swig_assert(cvar.ptr_zero is not None, "ptr_zero")
