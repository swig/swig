%module cpp14_variable_templates

// C++14 variable templates: a %template instantiation of one is wrapped as
// a read only variable holding the value of the instantiated template.

%inline %{
// Variable template parameterised on a type T - the typical use, mirroring
// the std::*_v aliases in <type_traits>: a typed compile time constant
// derived from properties of T.
template<typename T>
constexpr int bits_in = sizeof(T) * 8;

// Variable template with a non-type integer parameter, holding the result
// of a non-trivial compile time computation.  Precomputing factorials at
// compile time avoids the runtime recursion on every call.
constexpr int compute_factorial(int n) {
  return n <= 1 ? 1 : n * compute_factorial(n - 1);
}

template<int N>
constexpr int factorial = compute_factorial(N);
%}

%template(bits_in_char) bits_in<char>;
%template(factorial_5)  factorial<5>;
%template(factorial_10) factorial<10>;
