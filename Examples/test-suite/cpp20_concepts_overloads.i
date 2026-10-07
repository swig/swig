%module cpp20_concepts_overloads

// C++20 concepts on overloaded function templates and on member operator overloads.  Three SWIG paths are exercised here
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
//   - function templates that share a name and signature and differ only by their requires-clause - a
//     requires-clause is part of a function template's signature, so these are distinct overloads and
//     neither is dropped.
//
// SWIG does not honour C++20 constraint subsumption, so a %template naming overloads that instantiate to the
// same signature but differ only by their constraints is rejected as ambiguous (see
// errors/cpp_template_constrained_overload.i).  Tests here therefore use the variants that SWIG can express:
// shared constraints with distinct arities, and disjoint constraints with distinct template parameter lists.

%rename(eq)   Box::operator==;
%rename(plus) Box::operator+;

// A target language that has no ref-qualifiers keeps one of Holder::get and drops the other.
%warnfilter(SWIGWARN_LANG_OVERLOAD_IGNORED, SWIGWARN_LANG_OVERLOAD_SHADOW) Holder::get;

%warnfilter(SWIGWARN_PARSE_REDEFINED) respaced;
%warnfilter(SWIGWARN_PARSE_REDEFINED) respaced_requirement;
%warnfilter(SWIGWARN_PARSE_REDEFINED) reclosed;

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

// Function templates with the same name and function signature told apart only by their requires-clause.
// They take different numbers of template parameters, so each %template below names exactly one of them.
template<typename T> requires std::integral<T>
T scale(T x) { return x * 2; }

// Instantiated as int scale(double), so the multiplication happens in floating point and only the
// result is truncated - an argument truncated first would give 6 rather than 7 for 3.5.
template<typename R, typename T> requires std::floating_point<T>
R scale(T x) { return R(x * 2); }

// A declaration and a definition whose constraints differ only in whitespace or template parameter names are one function template.
template<typename T> requires (sizeof(T) > 1) T respaced(T x);
template<typename T> requires (sizeof(T)>1) T respaced(T x) { return x + 1; }

template<typename T> requires requires (T t) { t + 1; } T respaced_requirement(T x);
template<typename T> requires requires (T t) { t+1; } T respaced_requirement(T x) { return x + 2; }

template<typename T, typename U> requires std::integral<T> && (sizeof(U) > 1) T renamed(T x, U y);
template<typename A, typename B> requires std::integral<A> && (sizeof(B)>1) A renamed(A x, B y) { return x + A(y); }

template<typename T> struct Wrapper {
  T t;
};
template<typename T> requires (sizeof(Wrapper<Wrapper<T> >) > 1) T reclosed(T x);
template<typename T> requires (sizeof(Wrapper<Wrapper<T>>) > 1) T reclosed(T x) { return x + 3; }

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

%template(scale_int)           scale<int>;
%template(scale_double_to_int) scale<int, double>;

%template(respaced)             respaced<int>;
%template(respaced_requirement) respaced_requirement<int>;
%template(renamed)              renamed<int, double>;
%template(reclosed)             reclosed<int>;

%template(get_int)    Holder::get<int>;
%template(get_double) Holder::get<double>;

%template(BoxInt)    Box<int>;
%template(BoxDouble) Box<double>;
