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

# Deduction from a reference drops the reference, so these are copies made at static
# initialisation time and do not follow global_int.
swig_check(cvar.from_ref, 11)
swig_check(cvar.from_cref, 11)

# auto& and auto* applied to a reference deduce 'int &' and 'int *', both still live.
swig_check(deref(cvar.ref_from_ref), 20)
swig_check(deref(cvar.ptr_from_ref), 20)

# The pointer is mutable, and its setter rebinds it instead of writing through it.
cvar.ptr_from_ref = other_address()
swig_check(deref(cvar.ptr_from_ref), 99)
swig_check(cvar.global_int, 20)

# A reference to const wraps by value and is live.
swig_check(cvar.cref_from_cref, 20)

# A cv-qualifier on the declaration is not added to the one deduced from a const initialiser, so the
# deduced type is 'const int' and not 'const const int'.
swig_check(cvar.cref_from_cint, 7)
swig_check(deref(cvar.cptr_from_cint), 7)
try:
    cvar.cptr_from_cint = 42
    raise RuntimeError("setting cptr_from_cint from an int should raise a TypeError")
except TypeError as e:
    swig_assert("int const *" in str(e), str(e))

# A forwarding reference bound to an lvalue is an lvalue reference, so it wraps as a pointer
# to the live object; bound to a literal it is an rvalue reference bound to a temporary.
swig_check(deref(cvar.fwd_lvalue), 20)
swig_check(deref(cvar.fwd_lvalue_ref), 20)
swig_check(deref(cvar.fwd_rvalue), 42)

# An array initialiser decays to a pointer to its first element.
swig_check(deref(cvar.array_decay), 1)
swig_check(deref(cvar.array_decay_ptr), 1)
swig_check(deref(cvar.carray_decay), 5)

# Being a pointer, assigning to it rebinds it and leaves the array it was initialised from alone.
cvar.array_decay = cvar.other_array
swig_check(deref(cvar.array_decay), 10)
swig_check(deref(cvar.int_array), 1)

# auto& binds to the array instead, so it keeps the array type, wrapped as the array itself.
swig_check(array_first(int_array_address()), 1)
swig_check(deref(cvar.array_ref), 1)

# Writing through the reference writes the array it is bound to.
cvar.array_ref = cvar.other_array
swig_check(deref(cvar.int_array), 10)

# The address of a non-static member is a pointer to member, the address of a static member a plain pointer.
swig_check(use_member_ptr(cvar.pt_instance, cvar.member_ptr), 5)
swig_check(use_member_ptr(cvar.pt_instance, cvar.member_ptr_decltype), 5)
swig_check(use_member_fn_ptr(cvar.pt_instance, cvar.member_fn_ptr), 6)
swig_check(call_fn0(cvar.static_fn_ptr), 2)
swig_check(deref(cvar.static_var_ptr), 3)

# Parentheses around the operand of '&', or around the whole address, leave it the address of what is named.
swig_check(deref(cvar.paren_ptr), 20)
swig_check(deref(cvar.paren_paren_ptr), 20)
swig_check(call_fn(cvar.paren_fn_ptr, 4), 5)
swig_check(deref(cvar.paren_static_var_ptr), 3)
swig_check(deref(cvar.paren_ptr_decltype), 20)
swig_check(deref(cvar.paren_address_decltype), 20)

# A reference bound to a string literal is a reference to the array, wrapped as the string it holds.
swig_check(cvar.ref_string, "text")
swig_check(cvar.fwd_string, "text")
swig_check(cvar.cref_string, "text")
swig_check(cvar.cref_post_string, "text")
swig_check(isinstance(cvar.ref_string_wide, str), False)

# A reference bound to a cast of a string literal is a reference to the pointer, wrapped as a pointer to it.
swig_check(string_deref(cvar.cref_string_cast), "text")
swig_check(first_byte(cvar.bytes_cast), ord("t"))
swig_check(first_char(cvar.void_cast), ord("t"))
