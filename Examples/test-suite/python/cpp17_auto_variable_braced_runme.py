from cpp17_auto_variable_braced import *

from swig_test_utils import swig_check

swig_check(cvar.int_var, 42)
swig_check(cvar.double_var, 1.5)
swig_check(cvar.bool_var, True)
swig_check(cvar.negative_var, -5)
swig_check(cvar.const_var, 7)
swig_check(cvar.copy_var, 11)
swig_check(string_var, "braced")

# The braced initialiser deduces a pointer the same way an '=' initialiser does.
swig_check(deref(cvar.ptr_var), 11)
