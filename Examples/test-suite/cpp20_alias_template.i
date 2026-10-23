%module cpp20_alias_template

// C++20 alias templates with concept constraints.  Three forms are exercised:
//   1. Unconstrained                                 - baseline
//   2. Type-constraint in parameter list (shorthand) - 'template<Numeric T> using ...'
//   3. requires-clause (long form)                   - 'template<typename T> requires Numeric<T> using ...'
// Plus a best-effort case where the concept name has not been parsed by SWIG.
// Each alias resolves to the same underlying Box<T>, so all four aliases share
// the single wrapped class instantiated by '%template(BoxInt) Box<int>'.

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
class Box {
  T v;
public:
  Box() : v(T()) {}
  Box(T x) : v(x) {}
  T get() const { return v; }
  void set(T x) { v = x; }
};

// 1. Unconstrained alias template.
template<typename T>
using PlainBox = Box<T>;

// 2. Type-constraint in the template parameter list.
template<Numeric T>
using NumBox = Box<T>;

// 3. requires-clause form (equivalent to 2).
template<typename T> requires Numeric<T>
using ReqBox = Box<T>;
%}

// 4. Concept declared only in a raw '%{ %}' block - SWIG does not parse it but
//    the C++ compiler does.  The parm is silently remapped to 'typename T' and
//    the wrapper compiles because the concept is in scope at wrapper compile
//    time.  Mirrors the 'Hashable' pattern in cpp20_concepts_constrained_param.i.
%{
template<typename T>
concept UnseenConcept = std::integral<T>;
%}

%inline %{
template<UnseenConcept T>
using UnseenBox = Box<T>;

PlainBox<int>  make_plain (int v) { return PlainBox<int>(v); }
NumBox<int>    make_num   (int v) { return NumBox<int>(v); }
ReqBox<int>    make_req   (int v) { return ReqBox<int>(v); }
UnseenBox<int> make_unseen(int v) { return UnseenBox<int>(v); }
%}

%template(BoxInt) Box<int>;

// Each alias must be added to the type system with an empty %template(),
// matching the pattern documented in CPlusPlus11.html section
// 'Type alias and alias templates'.
%template() PlainBox<int>;
%template() NumBox<int>;
%template() ReqBox<int>;
%template() UnseenBox<int>;
