from cpp11_auto_variable_list import *

from swig_test_utils import swig_check

# Every declarator in the list is wrapped, with the type deduced from the first initialiser.
swig_check(cvar.int_first, 1)
swig_check(cvar.int_second, 2)

swig_check(cvar.double_first, 1.5)
swig_check(cvar.double_second, 2.5)

swig_check(cvar.const_first, 10)
swig_check(cvar.const_second, 20)

# Only the declarator carrying the '*' is a pointer, the other is an int.
swig_check(cvar.plain_first, 3)
swig_check(cvar.plain_second, 4)
swig_check(deref(cvar.ptr_first), 11)
swig_check(deref(cvar.ptr_second), 11)

# The first initialiser is not one a type can be deduced from, so the second declarator provides it.
swig_check(cvar.late_first, 1)
swig_check(cvar.late_second, 5)
