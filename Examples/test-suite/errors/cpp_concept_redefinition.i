%module xxx

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

// Two function templates with the same name and signature, differing only by their requires-clause.
// A requires-clause is part of a function template's signature, so these are two distinct overloads
// and neither is ignored - no warning here.  A %template naming both is a different matter and is
// rejected as ambiguous, see cpp_template_constrained_overload.i.
template<typename T> requires std::integral<T>
T process(T x) { return x + 1; }

template<typename T> requires std::floating_point<T>
T process(T x) { return T(x * 2.0); }

// Members of a class template that share a signature and differ only by a trailing requires-clause are
// still ignored, as SWIG cannot tell which one an instantiation selects.  Warning 333 says so, and the
// wrapper generated from the declaration that is kept calls whichever the C++ compiler selects.
template<typename T>
class Box {
public:
  Box(T v) requires std::integral<T>       { (void)v; }
  Box(T v) requires std::floating_point<T> { (void)v; }
  int kind() requires std::integral<T>       { return 1; }
  int kind() requires std::floating_point<T> { return 2; }
};

// A constraint spelt differently only in whitespace is the same constraint, so this is a redefinition.
template<typename T>
class Spaced {
public:
  int size() requires (sizeof(T) > 4) { return 1; }
  int size() requires (sizeof(T)>4) { return 2; }
};
%}

// An instantiation reports a redefined member with the same warning as its class template.
%template(BoxInt) Box<int>;
%template(SpacedDouble) Spaced<double>;
