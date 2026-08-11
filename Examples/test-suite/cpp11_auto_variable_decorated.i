%module cpp11_auto_variable_decorated

// C++11 'auto' variables - decorated declarators.  The 'auto' placeholder can carry the usual
// declarator decorations (reference, rvalue reference, pointer, cv-qualifiers) in the same way as an
// 'auto' function parameter, see cpp20_abbreviated_template_decorated.i.

// A reference cannot be reseated, so only the getter makes sense.  global_ptr is read only too as a
// setter for it is not what is under test here.
%immutable global_ptr;
%immutable ref_var;
%immutable rref_var;

// The '&global_int' initialisers are not ones SWIG can deduce a type from, so the pointer variables
// are dropped.  Only the deduction is missing here - the declarator itself is parsed.
%warnfilter(SWIGWARN_CPP11_AUTO) ptr;
%warnfilter(SWIGWARN_CPP11_AUTO) cptr;
%warnfilter(SWIGWARN_CPP11_AUTO) cptr_post;
%warnfilter(SWIGWARN_CPP11_AUTO) ptr_const;
%warnfilter(SWIGWARN_CPP11_AUTO) cptr_const;
%warnfilter(SWIGWARN_CPP11_AUTO) ptr_ptr;
%warnfilter(SWIGWARN_CPP11_AUTO) fn_ptr;

#if defined(SWIGC)
// TODO: Fix the experimental C backend emitting 'int &&**' for an rvalue reference variable.
%ignore rref_var;
#endif

%inline %{
int global_int = 11;
int *global_ptr = &global_int;
int global_fn(int x) { return x + 1; }

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
%}

%{
// Wunused-variable warning suppression for the variables SWIG drops.
bool warning_suppression() {
  return *cptr != 0 && *cptr_post != 0 && *ptr_const != 0 && *cptr_const != 0;
}
%}
