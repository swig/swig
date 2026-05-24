%module cpp20_abbreviated_template

// C++20 abbreviated function templates - 'auto' as a parameter type in an ordinary function.  Each auto
// parameter introduces an invented type template parameter (per [dcl.fct]/19), so the function becomes
// a function template that the user can instantiate with %template just like a regular template.
//
// The function must declare an explicit (non-auto) return type for SWIG to wrap it - SWIG cannot deduce
// auto return types (this restriction is shared with the C++14 auto return feature; see the existing
// cpp14_auto_return_type.i test and docs).

// 'Numeric auto fn(int x) { ... }' and 'Numeric auto fn(int x);' parse cleanly but the return type
// stays 'auto', so SWIG cannot deduce the actual return type and ignores the function with a warning.
// Suppress the warning per declaration so the test build is clean while still exercising the parser.
%warnfilter(SWIGWARN_CPP14_AUTO) half_numeric;
%warnfilter(SWIGWARN_CPP14_AUTO) times2;
%warnfilter(SWIGWARN_CPP14_AUTO) times3;

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept Sized = (sizeof(T) <= 8);

// Single auto parameter, explicit int return.
int twice(auto x) { return x + x; }

// Two auto parameters, explicit double return.
double scale(auto x, auto factor) { return x * factor; }

// Three auto parameters, explicit int return.
int sum3(auto a, auto b, auto c) { return a + b + c; }

// Unnamed auto parameter - the invented type template parameter is still introduced even though the parm has no name.
int unnamed_auto(auto) { return 42; }

// Constrained auto - a type-constraint precedes the auto placeholder.  The constraint rides as an attached
// constraint on the invented type template parameter and the function instantiates as if 'template<typename T> requires Numeric<T>'.
int twice_numeric(Numeric auto x) { return x + x; }

// Mixed type-constraints - each constrained auto parm carries its own.
double scale_mixed(Numeric auto x, Numeric auto factor) { return x * factor; }

// Same type-constraint on multiple parms - each parm becomes its own invented type template parameter, both constrained.
int add_same_concept(Sized auto a, Sized auto b) { return a + b; }

// Unnamed constrained auto - the type-constraint still applies to the invented type template parameter.
int unnamed_constrained(Numeric auto) { return 42; }

// Plain auto return type with an explicit trailing return type - SWIG wraps the trailing return type.
// A type-constraint on the return ('Numeric auto fn(...) -> int') is rejected by clang and MSVC, so the
// constrained-return case is exercised separately below without the trailing return type.
auto half(int x) -> int { return x / 2; }

// Constrained auto parameter with an explicit trailing return type; trailing 'int' is the wrapped type.
auto cube_constrained(Sized auto x) -> int { return x * x * x; }

// Plain auto return type plus a constrained auto parameter and a trailing return type - both sides wrap.
auto twice_n_arrow(Numeric auto x) -> int { return x + x; }

// Constrained auto return type without a trailing return type - parses but ignored with warning since SWIG cannot deduce the return type.
Numeric auto half_numeric(int x) { return x / 2; }

// Constrained auto return type without a trailing return type - parses but ignored with warning since SWIG cannot deduce the return type.
Numeric auto times2(int x) { return x * 2; }

// Constrained auto return type, declaration form - same ignored with warning fate.
Numeric auto times3(int x);
%}

%template(twice_int)              twice<int>;
%template(twice_short)            twice<short>;
%template(scale_id)               scale<int, double>;
%template(sum3_iii)               sum3<int, int, int>;
%template(unnamed_auto_int)       unnamed_auto<int>;
%template(twice_numeric_int)      twice_numeric<int>;
%template(scale_mixed_id)         scale_mixed<int, double>;
%template(add_same_int)           add_same_concept<int, int>;
%template(unnamed_constrained_int) unnamed_constrained<int>;
%template(cube_constrained_int)   cube_constrained<int>;
%template(twice_n_arrow_int)      twice_n_arrow<int>;
