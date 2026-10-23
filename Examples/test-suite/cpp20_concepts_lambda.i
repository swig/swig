%module cpp20_concepts_lambda

// Concepts and requires-clauses on C++20 templated lambdas.  Lambdas themselves are not wrapped (per the
// existing cpp20_lambda_template.i and the manual section "Lambda templates"), but the parser must
// accept the requires-clause syntax and the lambda must remain callable from a wrapped function.
//
// Per [expr.prim.lambda.general], a lambda may carry a template-parameter-list (since C++14 for generic
// lambdas with auto, since C++20 for explicit '<typename T>' parameters), an optional prefix
// requires-clause between the template head and the lambda-declarator, and an optional trailing
// requires-clause at the end of the lambda-declarator (after a trailing-return-type when one is
// present).  All these forms are accepted on templated lambdas; the auto parameter case is a separate
// preexisting limitation - documented at the bottom of the file.

%warnfilter(SWIGWARN_CPP11_LAMBDA);

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept Sized = (sizeof(T) <= 8);

// 1. Templated lambda with a trailing requires-clause - bare concept.
auto trailing = []<typename T>(T x) requires Numeric<T> { return x + x; };

// 2. Trailing requires-clause - compound '&&'.
auto compound = []<typename T>(T x) requires Numeric<T> && Sized<T> { return x + x; };

// 3. Trailing requires-clause - inline 'requires requires' with a simple-requirement.
auto inline_req = []<typename T>(T a, T b) requires requires(T t) { t + t; } { return a + b; };

// 4. Templated lambda with 'mutable' followed by a trailing requires-clause.  The C++20 grammar puts
// requires-clause after the decl-specifier-seq (mutable, constexpr, etc.) inside lambda-declarator.
auto with_mut = []<typename T>(T x) mutable requires Numeric<T> { return x + x; };

// 5. Prefix requires-clause on a templated lambda, between '<typename T>' and the parameter list.
auto prefix = []<typename T> requires Numeric<T> (T x) { return x + x; };

// 6. Prefix requires-clause on a templated lambda with no parameter list.
auto prefix_no_parms = []<typename T> requires Numeric<T> { return T(7); };

// 7. Trailing return type combined with a trailing requires-clause - the C++20 grammar puts the
// requires-clause after the trailing-return-type.
auto with_ret = []<typename T>(T x) -> T requires Numeric<T> { return x + x; };

// 8. Both prefix and trailing requires-clauses on the same lambda.
auto both_clauses = []<typename T> requires Numeric<T> (T x) requires Sized<T> { return x + x; };

// 9. Constrained auto parameter lambda - the 'Numeric auto' form (see cpp20_abbreviated_template
// for the same idea applied to ordinary functions).
auto auto_param = [](Numeric auto x) { return x + x; };

// Lambdas are not directly wrapped, so call each through an ordinary wrapped function.
int run_trailing(int x)            { return trailing(x); }
int run_compound(int x)            { return compound(x); }
int run_inline_req(int a, int b)   { return inline_req(a, b); }
int run_with_mut(int x)            { return with_mut(x); }
int run_prefix(int x)              { return prefix(x); }
int run_prefix_no_parms()          { return prefix_no_parms.template operator()<int>(); }
int run_with_ret(int x)            { return with_ret(x); }
int run_both_clauses(int x)        { return both_clauses(x); }
int run_auto_param(int x)          { return auto_param(x); }
%}
