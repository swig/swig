%module cpp20_concepts_constrained_param

// C++20 type constrained template parameters: 'template<Concept T>' as a
// shorthand for 'template<typename T> requires Concept<T>'.  Covers the
// single parm form, mixed type-constraint and plain typename, ::-qualified
// concept-ids, variadic packs, default arguments, and constrained class
// templates.

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept SmallNumeric = Numeric<T> && (sizeof(T) <= 4);

template<typename T>
concept FloatingPoint = std::floating_point<T>;

namespace nest {
  template<typename T>
  concept Integral = std::integral<T>;
}

// 1. Textbook form: single type constrained parameter.
template<Numeric T>
T cube(T x) { return x * x * x; }

// 2. ::-qualified concept-id.
template<nest::Integral T>
T half(T x) { return x / 2; }

// 3. Mixed type-constraint + plain typename in the same head.
template<Numeric T, typename U>
T scale(T x, U factor) { return T(x * factor); }

// 4. Default template argument paired with a type-constraint.
template<Numeric T = int>
T identity(T x) { return x; }

// 5. Two type-constraints in one head, one of them refining the other.
template<Numeric T, SmallNumeric U>
T combine(T x, U y) { return x + T(y); }

// 6. Variadic type constrained pack.
template<Numeric... Ts>
int count_numeric(Ts...) { return int(sizeof...(Ts)); }

// 6a. Leading plain typename followed by a type constrained pack.
template<typename X, Numeric... Ts>
int tag_count(X, Ts...) { return int(sizeof...(Ts)); }

// 6b. Two type-constraints with the trailing one a variadic pack.
template<SmallNumeric X, Numeric... Ts>
int small_tag_count(X, Ts...) { return int(sizeof...(Ts)); }

// 7. Constrained class template.
template<Numeric T>
class Box {
  T v;
public:
  Box() : v(T()) {}
  Box(T x) : v(x) {}
  T get() const { return v; }
  void set(T x) { v = x; }
};

// 8. Constrained class template, locally defined ::-qualified concept-id.
template<FloatingPoint T>
class FloatBox {
  T v;
public:
  FloatBox() : v(T()) {}
  FloatBox(T x) : v(x) {}
  T get() const { return v; }
};
%}

// 9. Concept declared only in a raw '%{ %}' block - SWIG does NOT parse it but
//    the C++ compiler does.  The parm is silently remapped to 'typename T' and
//    the wrapper compiles and runs because 'Hashable' is in scope at
//    wrapper compile time.
%{
#include <concepts>

template<typename T>
concept Hashable = std::integral<T>;
%}

%inline %{
template<Hashable T>
T tag(T x) { return x + T(1); }
%}

// 10. Template-id concept-id - the concept-id itself carries template arguments
//     before the parameter name.  Equivalent to 'requires Concept<T, args...>'.

// 10a. STL template-id concept-id.  'std::convertible_to' is declared in
//      <concepts> which SWIG does not parse, but the parm is silently remapped
//      and the wrapper compiles because the concept is visible to the C++
//      compiler.
%inline %{
template<std::convertible_to<int> T>
int to_int(T x) { return (int)x; }
%}

// 10b. STL template-id concept-id on a class template (verifies the
//      classifier treats the template parameter list of a class template the
//      same as for a function template).  'get()' returns int to exercise the
//      'T -> int' conversion the 'std::convertible_to<int>' constraint asserts.
%inline %{
template<std::convertible_to<int> T>
class ConvertibleCrate {
  T v;
public:
  ConvertibleCrate() : v(T()) {}
  ConvertibleCrate(T x) : v(x) {}
  int get() const { return (int)v; }
};
%}

%inline %{
// 10c. User defined 2-parameter concept used in template-id form.  The
//      classifier resolves 'Pair' and remaps the parm to 'typename T' plus a
//      'concept-id' constraint atom carrying the full 'Pair<(int)>' string.
template<typename T, typename U>
concept Pair = std::convertible_to<T, U>;

template<Pair<int> T>
int first_int(T x) { return (int)x; }

// 10d. Variadic template-id concept-id pack.
template<Pair<int>... Ts>
int count_pair(Ts...) { return int(sizeof...(Ts)); }

// 10e. Default template argument with a template-id concept-id.
template<Pair<int> T = double>
int with_default(T x) { return (int)x; }

// 10f. Constrained class template with a template-id concept-id.
template<Pair<int> T>
class Crate {
  T v;
public:
  Crate() : v(T()) {}
  Crate(T x) : v(x) {}
  T get() const { return v; }
};

// 10g. ::-qualified template-id concept-id.
namespace nest {
  template<typename T, typename U>
  concept NestPair = std::convertible_to<T, U>;
}
template<nest::NestPair<int> T>
int nested_pair(T x) { return (int)x; }
%}

%template(cube_int) cube<int>;
%template(cube_double) cube<double>;
%template(half_int) half<int>;
%template(scale_di) scale<double, int>;
%template(identity_int) identity<int>;
%template(combine_id) combine<int, char>;
%template(count_numeric_1) count_numeric<int>;
%template(count_numeric_3) count_numeric<int, double, char>;
%template(tag_count_si)    tag_count<const char *, int>;
%template(tag_count_s3)    tag_count<const char *, int, double, char>;
%template(small_tag_count_ci) small_tag_count<char, int>;
%template(small_tag_count_c3) small_tag_count<char, int, double, char>;
%template(BoxInt) Box<int>;
%template(BoxDouble) Box<double>;
%template(FloatBoxFloat) FloatBox<float>;
%template(tag_int) tag<int>;
%template(to_int_d)         to_int<double>;
%template(ConvertibleCrateDouble)   ConvertibleCrate<double>;
%template(first_int_d)      first_int<double>;
%template(count_pair_1)     count_pair<int>;
%template(count_pair_3)     count_pair<int, double, char>;
%template(with_default_int) with_default<int>;
%template(with_default_d)   with_default<double>; // TODO exact argument count needed. Does not work: with_default<>;
%template(CrateInt)         Crate<int>;
%template(CrateDouble)      Crate<double>;
%template(nested_pair_d)    nested_pair<double>;
