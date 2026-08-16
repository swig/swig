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
// requires-clauses warn 302 and the later declaration is dropped, and a %template naming overloads that instantiate
// to the same signature but differ only by their constraints is rejected as ambiguous (see
// errors/cpp_template_constrained_overload.i).  Tests here therefore use the variant that SWIG can express:
// shared constraints with distinct arities.

%rename(eq)   Box::operator==;
%rename(plus) Box::operator+;

// A target language that has no ref-qualifiers keeps one of Holder::get and drops the other.
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) Holder::get;

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

// Member function templates told apart by their ref-qualifier and cv-qualifier rather than by arity.
// Those are part of the function signature, so the constraints do not have to be evaluated to choose.
struct Holder {
  int value;
  Holder() : value(0) {}

  template<typename T> T get(T x) & requires std::integral<T> { return x + value; }
  template<typename T> T get(T x) const & requires std::floating_point<T> { return x - value; }
};

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

%template(get_int)    Holder::get<int>;
%template(get_double) Holder::get<double>;

%template(BoxInt)    Box<int>;
%template(BoxDouble) Box<double>;
