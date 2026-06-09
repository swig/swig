%module cpp20_concepts_overloads

// C++20 concepts on overloaded function templates and on member operator overloads.  Two SWIG paths are exercised here
// that the core concept tests don't reach:
//
//   - overload by arity dispatch on function templates that each carry their own requires-clause - the constraint
//     must be parsed without disturbing SWIG's existing overload handling, and the shared name plus distinct arities
//     must still produce the usual __SWIG_0/__SWIG_1 dispatcher.
//
//   - member operator overloads with trailing requires-clauses - operator wrapping has its own SWIG path
//     (renaming, dispatcher generation), and a constraint sitting between the parameter list and the function
//     body mustn't trip up that path.
//
// SWIG does not honour C++20 constraint subsumption: two function templates with identical signatures but disjoint
// requires-clauses warn 302 and the later declaration is dropped, and same name overloads with disjoint constraints
// fail to compile because SWIG instantiates every candidate rather than the most constrained one.  Tests here
// therefore use the variant that SWIG can express: shared constraints with distinct arities.

%rename(eq)   Box::operator==;
%rename(plus) Box::operator+;

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

// Function template overloaded on arity, all branches sharing the same requires-clause.  SWIG dispatches by argument count at runtime.
template<typename T> requires Numeric<T>
T accumulate(T a) { return a + 1; }

template<typename T> requires Numeric<T>
T accumulate(T a, T b) { return a + b; }

template<typename T> requires Numeric<T>
T accumulate(T a, T b, T c) { return a + b + c; }

// Class template with member operator overloads, each carrying its own trailing requires-clause.
template<typename T>
struct Box {
  T v;
  Box() : v(T()) {}
  Box(T x) : v(x) {}

  bool operator==(const Box& other) const requires Numeric<T> {
    return v == other.v;
  }

  Box operator+(const Box& other) const requires Numeric<T> {
    return Box(v + other.v);
  }
};
%}

%template(accumulate_int)    accumulate<int>;
%template(accumulate_double) accumulate<double>;

%template(BoxInt)    Box<int>;
%template(BoxDouble) Box<double>;
