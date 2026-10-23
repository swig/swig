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

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) int_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ref_from_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) ptr_from_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_lvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_lvalue_ref;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) fwd_rvalue;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) array_decay;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) array_decay_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) carray_decay;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) cptr_from_cint;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) static_var_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_paren_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_static_var_ptr;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_ptr_decltype;
%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK) paren_address_decltype;

#if defined(SWIGC)
// TODO: Fix the experimental C backend emitting 'int (*)(int)*' for a function pointer.
%ignore call_fn;
%ignore fn_ptr;
%ignore paren_fn_ptr;
// TODO: Fix the experimental C backend emitting 'int [4]*' for an array variable and 'int (*)[4]*'
// for a pointer to an array.
%ignore array_ref;
%ignore ref_string;
%ignore fwd_string;
%ignore cref_string;
%ignore cref_post_string;
%ignore ref_string_wide;
%ignore array_first;
%ignore int_array_address;
// TODO: Fix the experimental C backend's member pointer support (see member_pointer in FAILING_CPP_TESTS).
%ignore member_ptr;
%ignore static_fn_ptr;
%ignore call_fn0;
%ignore member_fn_ptr;
%ignore member_ptr_decltype;
%ignore use_member_ptr;
%ignore use_member_fn_ptr;
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
const char *string_deref(const char *const *p) { return *p; }
int first_byte(const unsigned char *p) { return p[0]; }
int first_char(const void *p) { return *static_cast<const char *>(p); }

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

const int cint = 7;

// A cv-qualifier on the declaration is the deduced type's own cv-qualifier rather than an addition to one
// deduced from a const initialiser.
const auto& cref_from_cint = cint;   // const int &
const auto* cptr_from_cint = &cint;  // const int *

// auto&& is a forwarding reference, so it is an lvalue reference when the initialiser is an lvalue
// and an rvalue reference when it is not.
auto&& fwd_lvalue = global_int;      // int &
auto&& fwd_lvalue_ref = int_ref;     // int &
auto&& fwd_rvalue = 42;              // int &&

int int_array[4] = {1, 2, 3, 4};
int other_array[4] = {10, 20, 30, 40};
const int cint_array[3] = {5, 6, 7};

int (*int_array_address())[4] { return &int_array; }

// An array initialiser decays to a pointer to its first element, unless the variable is a reference.
auto array_decay = int_array;        // int *
auto* array_decay_ptr = int_array;   // int *
auto carray_decay = cint_array;      // const int *
auto& array_ref = int_array;         // int (&)[4], wrapped as int [4]

struct Pt {
  int a;
  int m() const { return a + 1; }
  static int sm() { return 2; }
  static int sv;
};
int Pt::sv = 3;
Pt pt_instance = { 5 };

int call_fn0(int (*fn)()) { return fn(); }
int use_member_ptr(const Pt &p, int Pt::*mp) { return p.*mp; }
int use_member_fn_ptr(const Pt &p, int (Pt::*mfp)() const) { return (p.*mfp)(); }

// The address of a qualified non-static member is a pointer to member, the address of a static member a plain pointer.
auto member_ptr = &Pt::a;                        // int Pt::*
auto member_fn_ptr = &Pt::m;                     // int (Pt::*)() const
decltype(&Pt::a) member_ptr_decltype = &Pt::a;   // int Pt::*
auto static_fn_ptr = &Pt::sm;                    // int (*)()
auto static_var_ptr = &Pt::sv;                   // int *

// Parentheses around the operand of '&', or around the whole address, leave it the address of what is named.
char global_char = 'c';
auto paren_ptr = &(global_int);                                  // int *
auto paren_paren_ptr = &((global_int));                          // int *
auto paren_char_ptr = &(global_char);                            // char *
auto paren_fn_ptr = &(global_fn);                                // int (*)(int)
auto paren_static_var_ptr = &(Pt::sv);                           // int *
decltype(&(global_int)) paren_ptr_decltype = &global_int;        // int *
decltype((&global_int)) paren_address_decltype = &global_int;    // int *

// A reference binds to the array of characters a string literal is, not to the pointer it decays to.
auto& ref_string = "text";              // const char (&)[5]
auto&& fwd_string = "text";             // const char (&)[5]
const auto& cref_string = "text";       // const char (&)[5]
auto const& cref_post_string = "te" "xt";  // const char (&)[5]
auto& ref_string_wide = L"text";        // const wchar_t (&)[5]

// A cast of a string literal is a pointer, so the reference binds to that pointer rather than to an array.
const auto& cref_string_cast = (const char *)"text";  // const char *const &

// A cast of a string literal to any other pointer type is that type too.
const auto *const bytes_cast = (const unsigned char *)"text";  // const unsigned char *const
auto *const void_cast = (const void *)"text";                  // const void *const
%}
