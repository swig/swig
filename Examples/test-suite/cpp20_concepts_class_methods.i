%module cpp20_concepts_class_methods

// Member function templates of a non-templated class, constrained by C++20 concepts (trailing, prefix, requires-expression, static, multi param).

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept Addable = requires(T t) { t + t; };

class Calculator {
public:
  // Trailing requires-clause on a member function template.
  template<typename T>
  T cube(T x) const requires Numeric<T> {
    return x * x * x;
  }

  // Prefix requires-clause on a member function template.
  template<typename T> requires Numeric<T>
  T quad(T x) const {
    return x * x * x * x;
  }

  // Static member function template with a trailing requires-clause whose constraint is an inline requires-expression.
  template<typename T>
  static T sum(T a, T b) requires requires(T t) { t + t; } {
    return a + b;
  }

  // Member function template constrained by a named concept whose body is itself a requires-expression.
  template<typename T> requires Addable<T>
  T addn(T a, T b) const {
    return a + b;
  }

  // Member function template with two template parameters and a compound constraint joined by '&&'.
  template<typename T, typename U>
  requires Numeric<T> && Numeric<U>
  T scale(T x, U factor) const {
    return x * (T)factor;
  }
};
%}

%template(cube_int)      Calculator::cube<int>;
%template(cube_double)   Calculator::cube<double>;
%template(quad_int)      Calculator::quad<int>;
%template(sum_int)       Calculator::sum<int>;
%template(addn_int)      Calculator::addn<int>;
%template(scale_int_int) Calculator::scale<int, int>;
