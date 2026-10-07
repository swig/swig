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

// An auto parameter pack invents a template parameter pack, just as 'template<typename... T>' does, so
// the number of types given to %template is the number of parameters the wrapped function takes.
int sum_all(const auto&... args) { return (args + ... + 0); }

// Forwarding reference pack - the same promotion, spelled the way an abbreviated template usually is.
int sum_fwd(auto&&... args) { return (args + ... + 0); }

// Undecorated pack - the placeholder needs no reference or pointer decoration to introduce a pack.
int sum_bare(auto... args) { return (args + ... + 0); }

// Unnamed undecorated pack - the invented template parameter pack is introduced even with no parm name.
int unnamed_bare(auto...) { return 42; }

// Constrained auto parameter pack - the type-constraint applies to the invented template parameter pack.
int sum_numeric(const Numeric auto&... args) { return (args + ... + 0); }

// An ordinary parameter ahead of an auto parameter pack - only the pack is a template parameter, so the
// wrapped function takes one more parameter than the number of types given to %template.
int offset_sum(int first, const auto&... rest) { return first + (rest + ... + 0); }

// An auto parameter pack followed by another auto parameter.  The pack takes all but the last type given to
// %template and the last one types the trailing parameter, so the wrapper takes one parameter per type.  A
// pack that is not the last template parameter deduces to empty, so its types are the only ones the generated
// call has to name explicitly.
int pack_then_one(auto... values, auto last) { return (values + ... + 0) + last; }

// Two auto parameter packs - explicitly written template arguments all go to the first, leaving the
// second empty, so there is no limit on how many the instantiation may give.
int two_packs(auto... first, auto... second) { return (first + ... + 0) + (second + ... + 0); }

// An auto parameter pack followed by two ordinary auto parameters, so that the boundary between the
// pack and what follows it is more than one parameter wide.
int pack_then_two(auto... values, auto a, auto b) { return (values + ... + 0) + a + b; }

// An auto parameter pack followed by a plain parameter, which invents no template parameter of its own.
int pack_then_plain(auto... values, int last) { return int(sizeof...(values)) * 100 + last; }

// The same with a type-constraint on the pack.
int pack_then_plain_numeric(Numeric auto... values, double last) { return int(sizeof...(values)) * 100 + int(last); }

// The size of each pack rather than a sum over both, so that a wrong partition between them shows up.
int count_two_packs(auto... first, auto... second) { return int(sizeof...(first)) * 100 + int(sizeof...(second)); }
int count_pack_then_one(auto... values, auto last) { return int(sizeof...(values)) * 100 + int(last); }
int count_trailing_pack(int first, auto... rest) { return first * 100 + int(sizeof...(rest)); }

// The same shapes instantiated with more than one type.  Every %template above gives the same type
// throughout, which cannot tell a correct partition of the template arguments from one that happens
// to put the right number of types in each position.  Doubles are halved on the way in so a type that
// ends up in the wrong position changes the result rather than only the signature.
int mixed_pack_then_one(auto... values, auto last) { return (int(values * 2) + ... + 0) + int(last); }
int mixed_trailing_pack(auto first, auto... rest) { return int(first) + (int(rest * 2) + ... + 0); }

// Plain auto return type with an explicit trailing return type - SWIG wraps the trailing return type.
// A type-constraint on the return ('Numeric auto fn(...) -> int') is rejected by clang and MSVC, so the
// constrained-return case is exercised separately below without the trailing return type.
auto half(int x) -> int { return x / 2; }

// Constrained auto parameter with an explicit trailing return type; trailing 'int' is the wrapped type.
auto cube_constrained(Sized auto x) -> int { return x * x * x; }

// Plain auto return type plus a constrained auto parameter and a trailing return type - both sides wrap.
auto twice_n_arrow(Numeric auto x) -> int { return x + x; }

// A parameter is in scope in the trailing return type, so a decltype there names the parameter and not the
// global of the same name.  The parameter is a placeholder, so its type is the invented template parameter and
// the %template argument decides the return type.
int placeholder_name = 2;

auto shadow_placeholder(auto placeholder_name) -> decltype(placeholder_name) { return placeholder_name; }

// The decltype names the parameter it is spelled with, not just any placeholder parameter.
auto second_placeholder(auto first, auto second) -> decltype(second) { return second; }

// A type-constraint on the placeholder does not stop the decltype naming it.
auto constrained_arrow(Numeric auto value) -> decltype(value) { return value + value; }

// Constrained auto return type without a trailing return type - parses but ignored with warning since SWIG cannot deduce the return type.
Numeric auto half_numeric(int x) { return x / 2; }

// Constrained auto return type without a trailing return type - parses but ignored with warning since SWIG cannot deduce the return type.
Numeric auto times2(int x) { return x * 2; }

// Constrained auto return type, declaration form - same ignored with warning fate.
Numeric auto times3(int x);

// An auto parameter makes a constructor a constructor template, instantiated with %template.
struct AbbrevTag {
  int id;
  AbbrevTag() : id(3) {}
};
inline int abbrev_value(double x) { return int(x); }
inline int abbrev_value(const AbbrevTag &t) { return t.id; }

struct AbbrevCtor {
  int value;
  AbbrevCtor(auto x) : value(abbrev_value(x)) {}
};

struct AbbrevCtorExplicit {
  int value;
  explicit AbbrevCtorExplicit(auto x) : value(abbrev_value(x)) {}
};

struct AbbrevCtorConstrained {
  int value;
  AbbrevCtorConstrained(Numeric auto x) : value(abbrev_value(x)) {}
};

// Not instantiated, so there is no constructor to wrap, the same as for 'template<class T> AbbrevCtorNone(T)'.
struct AbbrevCtorNone {
  int value;
  AbbrevCtorNone(auto x) : value(abbrev_value(x)) {}
};
%}

%template(AbbrevCtor) AbbrevCtor::AbbrevCtor<int>;
%template(AbbrevCtor) AbbrevCtor::AbbrevCtor<AbbrevTag>;
%extend AbbrevCtorExplicit {
  %template(AbbrevCtorExplicit) AbbrevCtorExplicit<double>;
}
%template(AbbrevCtorConstrained) AbbrevCtorConstrained::AbbrevCtorConstrained<short>;

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
%template(shadow_placeholder_double) shadow_placeholder<double>;
%template(second_placeholder_id)  second_placeholder<int, double>;
%template(constrained_arrow_double) constrained_arrow<double>;
%template(sum_all_ii)             sum_all<int, int>;
%template(sum_all_iii)            sum_all<int, int, int>;
%template(sum_fwd_ii)             sum_fwd<int, int>;
%template(sum_bare_ii)            sum_bare<int, int>;
%template(sum_bare_iii)           sum_bare<int, int, int>;
%template(unnamed_bare_ii)        unnamed_bare<int, int>;
%template(sum_numeric_ii)         sum_numeric<int, int>;
%template(offset_sum_ii)          offset_sum<int, int>;
%template(pack_then_one_iii)      pack_then_one<int, int, int>;
%template(two_packs_ii)           two_packs<int, int>;
%template(pack_then_two_iiii)     pack_then_two<int, int, int, int>;
%template(pack_then_plain_ii)     pack_then_plain<int, int>;
%template(pack_then_plain_numeric_ii) pack_then_plain_numeric<int, int>;
%template(count_two_packs_ii)     count_two_packs<int, int>;
%template(count_two_packs_iii)    count_two_packs<int, int, int>;
// The empty second pack contributes no parameters to the declarator a directive matches.
%rename(count_two_packs_renamed) count_two_packs<int, int, int, int>(int, int, int, int);
%template(count_two_packs_iiii)   count_two_packs<int, int, int, int>;
%template(count_pack_then_one_iii) count_pack_then_one<int, int, int>;
%template(count_trailing_pack_ii) count_trailing_pack<int, int>;

// Mixed types in each of the pack shapes.
%template(mixed_pack_then_one_ddi) mixed_pack_then_one<double, double, int>;
%template(mixed_pack_then_one_idd) mixed_pack_then_one<int, double, double>;
%template(mixed_trailing_pack_idd) mixed_trailing_pack<int, double, double>;
%template(mixed_trailing_pack_did) mixed_trailing_pack<double, int, double>;
%template(pack_then_two_ddii)     pack_then_two<double, double, int, int>;
%template(two_packs_id)           two_packs<int, double>;
%template(offset_sum_id)          offset_sum<int, double>;
%template(sum_numeric_id)         sum_numeric<int, double>;
