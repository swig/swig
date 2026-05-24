%module cpp20_abbreviated_template_decorated

// C++20 abbreviated function templates - decorated 'auto' parms.  The 'auto' placeholder can carry
// the usual parameter decorations (reference, pointer, forwarding reference, CV-qualifiers) and a
// type-constraint.  SWIG must preserve the decoration on the wrapped parameter when promoting the
// 'auto' to an invented type template parameter.

%include <std_string.i>

%inline %{
#include <concepts>
#include <string>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

namespace {
  template<typename U> std::string to_text(U v) { return std::to_string(v); }
  template<> std::string to_text(std::string v) { return v; }
}

// h. auto& - reference to invented type.
int h_dec(auto& x) { return int(x); }

// i. auto* - pointer to invented type.
int i_dec(auto* x) { return int(*x); }

// j. auto&& - forwarding reference.
int j_dec(auto&& x) { return int(x); }

// k. const auto - const-qualified invented type passed by value.
int k_dec(const auto x) { return int(x); }

// l. const auto& - const reference to invented type.
int l_dec(const auto& x) { return int(x); }

// m. Numeric auto& - constrained reference.
int m_dec(Numeric auto& x) { return int(x); }

// n. const Numeric auto& - constrained const reference.
int n_dec(const Numeric auto& x) { return int(x); }

// o. Decorated auto mixed with an explicit template parameter list.  T = std::string,
// auto = int (the const ref to the auto parm flows through to the wrapper).
template<typename T>
std::string o_dec(T x, const auto& y) { return to_text(x) + ":" + to_text(y); }
%}

%template(h_dec_i)   h_dec<int>;
%template(i_dec_i)   i_dec<int>;
%template(j_dec_i)   j_dec<int>;
%template(k_dec_i)   k_dec<int>;
%template(l_dec_i)   l_dec<int>;
%template(m_dec_i)   m_dec<int>;
%template(n_dec_i)   n_dec<int>;
%template(o_dec_si)  o_dec<std::string, int>;
