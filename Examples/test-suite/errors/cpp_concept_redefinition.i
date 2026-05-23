%module xxx

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

// Two function templates with the same name and signature, differing only by their requires-clause.
// SWIG does not model C++20 constraint subsumption, so the second declaration is dropped with warning 302.
template<typename T> requires std::integral<T>
T process(T x) { return x + 1; }

template<typename T> requires std::floating_point<T>
T process(T x) { return T(x * 2.0); }

// Same limitation applies to constructor overloads that share a signature and differ only by requires-clause.
template<typename T>
class Box {
public:
  Box(T v) requires std::integral<T>       { (void)v; }
  Box(T v) requires std::floating_point<T> { (void)v; }
};
%}
