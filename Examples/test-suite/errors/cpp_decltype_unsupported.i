#ifdef SWIG
%module xxx
#endif

// Test that decltype cases where SWIG doesn't yet support deducing the type
// are handled gracefully.
//
// To check testcases are valid C++:
// g++ -std=c++20 -Wall -W -xc++ -c cpp_decltype_unsupported.i

// Function return type
static int func_returning_int(int x = 0) { return x; }
static int global_int = 42;
decltype(func_returning_int()) func_return;
decltype(func_returning_int(0)) func_return2;

// Address of (other than char or wchar_t)
decltype(&global_int) address_of;

// Pointer dereference (other than of char* or wchar_t*).
#ifdef SWIG
%ignore pointer_to_int;
#endif
int* pointer_to_int;
decltype(*pointer_to_int) pointer_dereference = *pointer_to_int;

// Variable SWIG doesn't know about.
#ifndef SWIG
static int undeclared_variable = 1;
#endif
decltype(undeclared_variable) unknown_to_swig;

// Constructed object.
struct A {};
decltype(A()) constructed_object;

// Spaceship operator.
#include <compare>
decltype(1 <=> 2) spaceship = (1 <=> 2);

// Array dereference.
decltype(("abc"[1])) array_deref = 0;
constexpr auto array_deref2{"abc"[1]};
// FIXME: SWIG fails to parse these cases:
#ifndef SWIG
decltype("abc"[1]) array_deref3 = 0;
constexpr auto array_deref4 = ("abc"[1]);
constexpr auto array_deref5("abc"[1]);
#endif

// Comparisons.
// FIXME SWIG fails to parse both these with `Error: Missing ')'. Reached end of input.`
//decltype(1 < 2) lt_test = 0;
//decltype(1 > 2) gt_test = 0;

// Assignment.
bool a;
decltype((a = true) + 1) assignment = true;
