<?php

require "tests.php";

check::functions(array('global_fn', 'deref', 'deref2', 'call_fn', 'first_element', 'first_byte', 'first_char', 'other_address', 'int_array_address',
                       'other_array_address', 'call_fn0', 'use_member_ptr', 'use_member_fn_ptr'));
check::classes(array('cpp11_auto_variable_decorated', 'Pt'));

// const auto& and auto const& deduce to 'const int &', wrapped by value.
check::equal(cref_var_get(), 11);
check::equal(cref_post_var_get(), 11);

// The references are live, so writing through global_int is visible via them.
global_int_set(20);
check::equal(cref_var_get(), 20);
check::equal(cref_post_var_get(), 20);

// auto& and auto&& deduce to 'int &' and 'int &&', which wrap as pointers.
check::equal(ref_var_get() !== null, true, "ref_var");
check::equal(rref_var_get() !== null, true, "rref_var");

// The pointer variables deduce to 'int *', so they can be passed to a function taking one.
check::equal(deref(ptr_get()), 20);
check::equal(deref(cptr_get()), 20);
check::equal(deref(cptr_post_get()), 20);
check::equal(deref(ptr_const_get()), 20);
check::equal(deref(cptr_const_get()), 20);

// auto** deduces to 'int **'.
check::equal(deref2(ptr_ptr_get()), 20);

// The address of a function deduces to a function pointer, so it can be called through.
check::equal(call_fn(fn_ptr_get(), 4), 5);

// An undecorated placeholder initialised from a pointer deduces the pointer type.
check::equal(deref(copy_ptr_get()), 20);
check::equal(deref(copy_ptr_decorated_get()), 20);

// Deduction from a reference drops the reference, so these are copies that do not follow global_int.
check::equal(from_ref_get(), 11);
check::equal(from_cref_get(), 11);

// auto& and auto* applied to a reference deduce 'int &' and 'int *', both still live.
check::equal(deref(ref_from_ref_get()), 20);
check::equal(deref(ptr_from_ref_get()), 20);

// The pointer is mutable, and its setter rebinds it instead of writing through it.
ptr_from_ref_set(other_address());
check::equal(deref(ptr_from_ref_get()), 99);
check::equal(global_int_get(), 20);

// A reference to const wraps by value and is live.
check::equal(cref_from_cref_get(), 20);

// A cv-qualifier on the declaration is not added to the one deduced from a const initialiser.
check::equal(cref_from_cint_get(), 7);
check::equal(deref(cptr_from_cint_get()), 7);
try {
  cptr_from_cint_set(42);
  check::fail("setting cptr_from_cint from an int should raise a TypeError");
} catch (TypeError $e) {
  check::str_contains($e->getMessage(), "SWIGTYPE_p_int", $e->getMessage());
}

// A forwarding reference is an lvalue reference when bound to an lvalue and an rvalue reference when bound to a literal.
check::equal(deref(fwd_lvalue_get()), 20);
check::equal(deref(fwd_lvalue_ref_get()), 20);
check::equal(deref(fwd_rvalue_get()), 42);

// An array initialiser decays to a pointer to its first element.
check::equal(deref(array_decay_get()), 1);
check::equal(deref(array_decay_ptr_get()), 1);
check::equal(deref(carray_decay_get()), 5);

// Being a pointer, assigning to it rebinds it and leaves the array it was initialised from alone.
array_decay_set(other_array_get());
check::equal(deref(array_decay_get()), 10);
check::equal(deref(int_array_get()), 1);

// auto& binds to the array instead, so it keeps the array type, wrapped as a pointer to the array.
check::equal(first_element(int_array_address()), 1);
check::equal(first_element(array_ref_get()), 1);

// Writing through the reference writes the array it is bound to.
array_ref_set(other_array_address());
check::equal(deref(int_array_get()), 10);

// The address of a non-static member is a pointer to member, the address of a static member a plain pointer.
check::equal(use_member_ptr(pt_instance_get(), member_ptr_get()), 5);
check::equal(use_member_ptr(pt_instance_get(), member_ptr_decltype_get()), 5);
check::equal(use_member_fn_ptr(pt_instance_get(), member_fn_ptr_get()), 6);
check::equal(call_fn0(static_fn_ptr_get()), 2);
check::equal(deref(static_var_ptr_get()), 3);

// Parentheses around the operand of '&', or around the whole address, leave it the address of what is named.
check::equal(deref(paren_ptr_get()), 20);
check::equal(deref(paren_paren_ptr_get()), 20);
check::equal(call_fn(paren_fn_ptr_get(), 4), 5);
check::equal(deref(paren_static_var_ptr_get()), 3);
check::equal(deref(paren_ptr_decltype_get()), 20);
check::equal(deref(paren_address_decltype_get()), 20);

// A reference bound to a string literal is a reference to the array, wrapped as the string it holds.
check::equal(ref_string_get(), "text");
check::equal(fwd_string_get(), "text");
check::equal(cref_string_get(), "text");
check::equal(cref_post_string_get(), "text");
check::equal(is_string(ref_string_wide_get()), false);

// A reference bound to a cast of a string literal is a reference to the pointer, wrapped as the string it points to.
check::equal(cref_string_cast_get(), "text");
check::equal(first_byte(bytes_cast_get()), ord("t"));
check::equal(first_char(void_cast_get()), ord("t"));

check::done();
