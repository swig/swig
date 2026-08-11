%module cpp11_auto_variable_decorated

// C++11 'auto' variables - decorated declarators.  The 'auto' placeholder can carry the usual
// declarator decorations (reference, rvalue reference, pointer, cv-qualifiers) in the same way as an
// 'auto' function parameter, see cpp20_abbreviated_template_decorated.i.

// A reference cannot be reseated, so only the getter makes sense.  The pointers are read only too as
// a setter for them is not what is under test here.
%immutable global_ptr;
%immutable ref_var;
%immutable rref_var;
%immutable ptr;
%immutable cptr;
%immutable cptr_post;
%immutable ptr_ptr;
%immutable copy_ptr;
%immutable copy_ptr_decorated;

#if defined(SWIGC)
// TODO: Fix the experimental C backend emitting 'int &&**' for an rvalue reference variable.
%ignore rref_var;
// TODO: Fix the experimental C backend emitting 'int (*)(int)*' for a function pointer.
%ignore call_fn;
%ignore fn_ptr;
#endif

%inline %{
int global_int = 11;
int *global_ptr = &global_int;
int global_fn(int x) { return x + 1; }

// Helpers proving the deduced type in the target language.
int deref(int *p) { return *p; }
int deref2(int **p) { return **p; }
int call_fn(int (*fn)(int), int x) { return fn(x); }

// auto& - lvalue reference to the deduced type.
auto& ref_var = global_int;

// const auto& - const lvalue reference.
const auto& cref_var = global_int;

// auto const& - the cv-qualifier may also follow the placeholder.
auto const& cref_post_var = global_int;

// auto&& - rvalue reference.
auto&& rref_var = 42;

// auto* - pointer.
auto* ptr = &global_int;

// const auto* - pointer to const.
const auto* cptr = &global_int;

// auto const* - the cv-qualifier may also follow the placeholder.
auto const* cptr_post = &global_int;

// auto* const - const pointer.
auto* const ptr_const = &global_int;

// const auto* const - const pointer to const.
const auto* const cptr_const = &global_int;

// auto** - pointer to pointer.
auto** ptr_ptr = &global_ptr;

// auto* initialised from a function address.
auto* fn_ptr = &global_fn;

// The declarator of the initialiser is part of the type deduced from it, so an undecorated placeholder
// initialised from a pointer deduces the pointer type itself.  Both of these are 'int *'.
auto copy_ptr = global_ptr;
auto* copy_ptr_decorated = global_ptr;
%}
