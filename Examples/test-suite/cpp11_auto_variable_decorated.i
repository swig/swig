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
// An array reference cannot be assigned in C++, so only the getter is generated.
%immutable array_ref;

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) int_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ref_from_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ptr_from_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_lvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_lvalue_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_rvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) array_decay;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) array_decay_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) carray_decay;

#if defined(SWIGC)
// TODO: Fix the experimental C backend emitting 'int &&**' for an rvalue reference variable.
%ignore rref_var;
%ignore fwd_rvalue;
// TODO: Fix the experimental C backend emitting 'int (*)(int)*' for a function pointer.
%ignore call_fn;
%ignore fn_ptr;
// TODO: Fix the experimental C backend emitting 'int [4]*' for an array reference variable and
// 'int (*)[4]*' for a pointer to an array parameter.
%ignore array_ref;
%ignore array_first;
#endif

%inline %{
int global_int = 11;
int *global_ptr = &global_int;
int global_fn(int x) { return x + 1; }

// Helpers proving the deduced type in the target language.
int deref(int *p) { return *p; }
int deref2(int **p) { return **p; }
int call_fn(int (*fn)(int), int x) { return fn(x); }
int array_first(int (*p)[4]) { return (*p)[0]; }

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

int &int_ref = global_int;
const int &cint_ref = global_int;

int other_int = 99;
int *other_address() { return &other_int; }

// An id-expression naming a reference has the type it refers to, so the reference is not part of
// what is deduced from it.
auto from_ref = int_ref;             // int
auto& ref_from_ref = int_ref;        // int &
auto* ptr_from_ref = &int_ref;       // int *
auto from_cref = cint_ref;           // int
auto& cref_from_cref = cint_ref;     // const int &

// auto&& is a forwarding reference, so it is an lvalue reference when the initialiser is an lvalue
// and an rvalue reference when it is not.
auto&& fwd_lvalue = global_int;      // int &
auto&& fwd_lvalue_ref = int_ref;     // int &
auto&& fwd_rvalue = 42;              // int &&

int int_array[4] = {1, 2, 3, 4};
int other_array[4] = {10, 20, 30, 40};
const int cint_array[3] = {5, 6, 7};

// An array initialiser decays to a pointer to its first element, unless the variable is a reference.
auto array_decay = int_array;        // int *
auto* array_decay_ptr = int_array;   // int *
auto carray_decay = cint_array;      // const int *
auto& array_ref = int_array;         // int (&)[4]
%}
