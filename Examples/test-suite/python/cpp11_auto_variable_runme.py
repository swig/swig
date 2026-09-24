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

# Parentheses around the initialiser do not change what is deduced.
swig_check(cvar.paren_int, 1)
swig_assert(isinstance(cvar.paren_int, int), "paren_int should be an int")
swig_check(cvar.paren_double, 1.0)
swig_assert(isinstance(cvar.paren_double, float), "paren_double should be a float")
swig_assert(cvar.paren_ptr is not None, "paren_ptr")
swig_assert(cvar.paren_nested_ptr is not None, "paren_nested_ptr")
swig_check(cvar.paren_nested, 1)

# A promoted narrow integral type is an int, so it holds a value the narrow type could not.
for name in ["promoted_short", "promoted_ushort", "promoted_char", "promoted_bool"]:
    setattr(cvar, name, 100000)
    swig_check(getattr(cvar, name), 100000)
swig_check(cvar.negated_short, -1)

# A typedef hiding const or an array does not stop deduction dropping or decaying it.
swig_check(cvar.typedef_const, 4)
cvar.typedef_const = 40
swig_check(cvar.typedef_const, 40)
swig_check(int_ptr_second(cvar.typedef_array), 6)
swig_check(int_ptr_second(cvar.typedef_array_ptr), 6)
swig_check(cvar.typedef_alias, 8)
