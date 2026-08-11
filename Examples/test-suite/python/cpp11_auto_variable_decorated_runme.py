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

# The pointer variables deduce to 'int *', so they can be passed to a function taking one.
swig_check(deref(cvar.ptr), 20)
swig_check(deref(cvar.cptr), 20)
swig_check(deref(cvar.cptr_post), 20)
swig_check(deref(cvar.ptr_const), 20)
swig_check(deref(cvar.cptr_const), 20)

# auto** deduces to 'int **'.
swig_check(deref2(cvar.ptr_ptr), 20)

# The address of a function deduces to a function pointer, so it can be called through.
swig_check(call_fn(cvar.fn_ptr, 4), 5)

# An undecorated placeholder initialised from a pointer deduces the pointer type.
swig_check(deref(cvar.copy_ptr), 20)
swig_check(deref(cvar.copy_ptr_decorated), 20)
