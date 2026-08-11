from cpp11_auto_variable_decorated import *

from swig_test_utils import swig_check, swig_assert

# const auto& and auto const& deduce to 'const int &', wrapped by value.
swig_check(cvar.cref_var, 11)
swig_check(cvar.cref_post_var, 11)

# The references are live, so writing through global_int is visible via them.
cvar.global_int = 20
swig_check(cvar.cref_var, 20)
swig_check(cvar.cref_post_var, 20)

# auto& and auto&& deduce to 'int &' and 'int &&', which wrap as pointers.
swig_assert(cvar.ref_var is not None, "ref_var")
swig_assert(cvar.rref_var is not None, "rref_var")
