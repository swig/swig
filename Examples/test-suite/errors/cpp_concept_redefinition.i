%module xxx

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

// Two function templates with the same name and signature, differing only by their requires-clause.
// A requires-clause is part of a function template's signature, so these are two distinct overloads
// and neither is dropped - no warning here.  A %template naming both is a different matter and is
// rejected as ambiguous, see cpp_template_constrained_overload.i.
template<typename T> requires std::integral<T>
T process(T x) { return x + 1; }

template<typename T> requires std::floating_point<T>
T process(T x) { return T(x * 2.0); }

// Constructor overloads that share a signature and differ only by a trailing requires-clause are still
// collapsed with warning 302.
template<typename T>
class Box {
public:
  Box(T v) requires std::integral<T>       { (void)v; }
  Box(T v) requires std::floating_point<T> { (void)v; }
};
%}
