%module xxx

%inline %{
#include <concepts>

// C++20 abbreviated function templates told apart only by their type-constraint.
int classify(std::integral auto value) { return 1; }
double classify(std::floating_point auto value) { return 2; }

// The same overloads written with an explicit template parameter list and a requires-clause.
template<typename T> requires std::integral<T> int rank(T value) { return 1; }
template<typename T> requires std::floating_point<T> double rank(T value) { return 2; }

// Member function templates carrying the same member qualifiers, so only the type-constraint
// tells them apart.
struct Holder {
  int get(std::integral auto x) const & { return 1; }
  double get(std::floating_point auto x) const & { return 2; }
};
%}

%template(classify_int) classify<int>;
%template(classify_double) classify<double>;
%template(rank_double) rank<double>;
%template(get_int) Holder::get<int>;

%inline %{
// Constraints differing in which template parameter they name, or in tokens a space keeps apart, are still different.
template<typename T, typename U> requires std::integral<T> int pick(U value) { return 1; }
template<typename T, typename U> requires std::integral<U> int pick(U value) { return 2; }
typedef unsigned long unsignedint;
template<typename T> requires (sizeof(T) > sizeof(unsigned int)) int wide(T value) { return 1; }
template<typename T> requires (sizeof(T) > sizeof(unsignedint)) int wide(T value) { return 2; }
%}

%template(pick_int) pick<int, int>;
%template(wide_double) wide<double>;

%inline %{
// A member function template declared twice with one constraint on the class template's parameter is a redefinition, not an overload.
template<typename T> struct Twice {
  template<typename U> int size(U value) requires (sizeof(T) > 4);
  template<typename U> int size(U value) requires (sizeof(T) > 4) { return 1; }
};
%}

%template(TwiceDouble) Twice<double>;
%extend Twice<double> {
  %template(size_int) size<int>;
}
