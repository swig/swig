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

// Variable SWIG doesn't know about.
#ifndef SWIG
static int undeclared_variable = 1;
#endif
decltype(undeclared_variable) unknown_to_swig;

// Spaceship operator.
#include <compare>
decltype(1 <=> 2) spaceship = (1 <=> 2);

// Array dereference in a braced initialiser, which SWIG keeps as text.
constexpr auto array_deref2{"abc"[1]};
// FIXME: SWIG parses no parenthesised direct initialisation, of any type, see issue #869.
#ifndef SWIG
constexpr auto array_deref5("abc"[1]);
#endif

// Comparisons.
decltype(1 < 2) lt_test = 0;
decltype(1 > 2) gt_test = 0;
constexpr auto lt_test2 = 1 < 2;
constexpr auto gt_test2 = 1 > 2;

// Assignment.
bool a;
decltype((a = true) + 1) assignment = true;

// Parameter.
void take_assignment(decltype(a = true) c, int n);
