%module cpp20_abbreviated_template_mixed

// C++20 lets the abbreviated function template form (an 'auto' parameter) be combined with an explicit
// template-parameter list.  Per [dcl.fct]/19 each 'auto' parameter introduces an invented type template
// parameter that is appended to the explicit parameter list.  When using %template the user supplies
// arguments for the explicit parameters first, then for each invented one in the order the auto parms
// appear in the function declaration.

%include <std_string.i>

%inline %{
#include <concepts>
#include <format>
#include <string>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

namespace {
  template<typename U> std::string to_text(U v) { return std::to_string(v); }
  template<> std::string to_text(std::string v) { return v; }
  template<> std::string to_text(const char* v) { return v; }
  // std::to_string(double) prints six fractional digits, but the count is locale- and
  // platform defined.  Force two digits via std::format so the runme expected strings are portable.
  template<> std::string to_text(double v) { return std::format("{:.2f}", v); }
  // Concatenate the to_text representation of each argument with '/' between them.  Every mix
  // function below uses this so the bodies are uniformly one line and the binding to each parm
  // shows up in the result string.  Variadic test cases wrap the pack in literal "[" / "]" markers
  // so the variadic absorbed args are visually distinguished from the non-variadic ones.
  template<typename First, typename... Rest>
  std::string join_text(First first, Rest... rest) {
    std::string result = to_text(first);
    ((result += "/", result += to_text(rest)), ...);
    return result;
  }
}

// a. Explicit typename followed by an auto parameter.
//    T binds to std::string, the invented auto parm binds to int.
template<typename T>
std::string a_mix(T x, auto y) { return join_text(x, y); }

// b. Auto parameter followed by an explicit typename.
//    auto binds to std::string, U binds to int.
template<typename U>
std::string b_mix(auto x, U y) { return join_text(x, y); }

// c. Two explicit parms surrounding an auto, with trailing return type.
//    T binds to int, auto to std::string, V to int.
template<typename T, typename V>
auto c_mix(T x, auto y, V z) -> std::string { return join_text(x, y, z); }

// d. Constrained explicit parm with a constrained auto parm.
//    Numeric T binds to int; Numeric auto binds to double - distinct enough that a binding swap
//    flips the formatting (e.g. "3/4.00" vs "4.00/3") in the result string.
template<Numeric T>
std::string d_mix(T x, Numeric auto y) { return join_text(x, y); }

// e. Two auto parms with an explicit typename between them.
//    First auto binds to std::string, T to int, second auto to std::string.
template<typename T>
std::string e_mix(auto x, T y, auto z) { return join_text(x, y, z); }

// Cases f..j combine 'auto' parms with a variadic explicit template pack.  Per
// C++20 [dcl.fct]/19 the invented type template-parameter for each 'auto' is
// appended after the explicit template-parameter list, so when that list ends
// in a pack the invented sits past the pack.  %template binding is positional:
// leading non-variadic parms bind one to one, the pack absorbs the middle
// args, and the trailing args bind to the invented parms in declaration order.

// f. Auto parm before a variadic pack.  Templateparms <Ts (variadic), invented>.
//    %template arg list <int, std::string, double> binds Ts={int, std::string} (absorbed by the pack),
//    invented=double (last arg).  Wrapper signature: f_mix(double x, int y1, std::string y2).
template<typename... Ts>
std::string f_mix(auto x, Ts... ys) { return join_text(x, "[", ys..., "]"); }

// g. Leading explicit, auto, variadic pack.  Templateparms <T, Ts (variadic), invented>.
//    %template arg list <int, std::string, double, std::string> binds T=int, Ts={std::string, double},
//    invented=std::string.  Wrapper signature: g_mix(int x, std::string y, std::string z1, double z2).
template<typename T, typename... Ts>
std::string g_mix(T x, auto y, Ts... zs) { return join_text(x, y, "[", zs..., "]"); }

// h. Constrained auto + variadic pack.  Templateparms <Ts (variadic), constrained invented>.
//    %template arg list <int, std::string, double> binds Ts={int, std::string}, invented=double.
//    Wrapper signature: h_mix(double x, int y1, std::string y2).
template<typename... Ts>
std::string h_mix(Numeric auto x, Ts... ys) { return join_text(x, "[", ys..., "]"); }

// i. Two auto parms surrounding a variadic pack.  Templateparms <Ts (variadic), invented1, invented2>
//    where invented1 is for x and invented2 is for z (declaration order).
//    %template arg list <int, std::string, double, int> binds Ts={int, std::string}, invented1=double,
//    invented2=int.  Wrapper signature: i_mix(double x, int y1, std::string y2, int z).  Exercises
//    function parm list variadic not last, since 'auto z' follows the pack.
template<typename... Ts>
std::string i_mix(auto x, Ts... ys, auto z) { return join_text(x, "[", ys..., "]", z); }

// j. Decorated auto + variadic pack.  'const auto&' invents a 'const __invented__&' parm.
//    %template arg list <int, std::string, double> binds Ts={int, std::string}, invented=double.
//    Wrapper signature: j_mix(const double& x, int y1, std::string y2).
template<typename... Ts>
std::string j_mix(const auto& x, Ts... ys) { return join_text(x, "[", ys..., "]"); }
%}

// The user supplies one %template argument for each template parameter, in order: every explicit
// parameter first, then one for each auto parameter in the declaration order.
%template(a_mix_si)   a_mix<std::string, int>;
// For b_mix the function signature is 'U b_mix(auto x, U y)'.  Template args go explicit first so
// <U=std::string, auto=int> means the wrapped signature is 'b_mix(int x, std::string y)'.  The
// suffix reflects the function parm order rather than the template arg order.
%template(b_mix_is)   b_mix<std::string, int>;
// c_mix(T x, auto y, V z) with template args <T=int, V=int, auto=std::string> -> wrapped (int, string, int).
%template(c_mix_isi)  c_mix<int, int, std::string>;
%template(d_mix_id)   d_mix<int, double>;
%template(e_mix_iss)  e_mix<int, std::string, std::string>;

// New variadic + auto cases.  Each %template arg list follows the C++20 [dcl.fct]/19 order:
// explicit non-variadics first, then args absorbed by the pack, then one per invented in
// declaration order.
%template(f_mix_isd)  f_mix<int, std::string, double>;
%template(g_mix_isds) g_mix<int, std::string, double, std::string>;
%template(h_mix_isd)  h_mix<int, std::string, double>;
%template(i_mix_isdi) i_mix<int, std::string, double, int>;
%template(j_mix_isd)  j_mix<int, std::string, double>;
