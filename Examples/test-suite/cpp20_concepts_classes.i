%module cpp20_concepts_classes

// C++20 concepts applied to class templates: prefix requires-clause, trailing requires on ordinary methods, compound '&&', constrained constructor.

%inline %{
#include <concepts>

template<typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template<typename T>
concept SmallNumeric = Numeric<T> && (sizeof(T) <= 4);

// Class template with a prefix requires-clause on the template head.
template<typename T>
requires Numeric<T>
class NumericBox {
  T value;
public:
  NumericBox() : value(T()) {}
  NumericBox(T v) : value(v) {}
  T get() const { return value; }
  void set(T v) { value = v; }
  T cube() const { return value * value * value; }
};

// Unconstrained class template whose ordinary methods carry their own trailing requires-clauses referencing the class's template parameter.
template<typename T>
class Holder {
  T value;
public:
  Holder() : value(T()) {}
  Holder(T v) : value(v) {}
  T get() const { return value; }
  void set(T v) { value = v; }

  // Trailing requires-clause on an ordinary method.
  T doubled() const requires Numeric<T> { return value + value; }
};

// Class template with a compound prefix requires-clause joined by '&&'.
template<typename T>
requires Numeric<T> && SmallNumeric<T>
class SmallBox {
  T value;
public:
  SmallBox() : value(T()) {}
  SmallBox(T v) : value(v) {}
  T get() const { return value; }
};

// Class template with a constrained constructor (the class is otherwise unconstrained, but only
// Numeric T values can construct from a value).  The constructor's trailing requires-clause is held
// on the constructor node's "constraint" attribute and is substituted when the class template is
// instantiated; both 'int' and 'double' satisfy 'Numeric<T>' so both instantiations succeed.
template<typename T>
class CheckedBox {
  T value;
public:
  CheckedBox() : value(T()) {}
  CheckedBox(T v) requires Numeric<T> : value(v) {}
  T get() const { return value; }
};

// Out of line definition of a member function template of a class template,
// with a prefix requires-clause on its own template head.  Exercises the
// requires_clause_opt path on a doubly templated declaration.
template<typename T>
class OutOfLineBox {
  T value;
public:
  OutOfLineBox(T v) : value(v) {}
  T get() const { return value; }
  template<typename U> requires Numeric<U>
  T scaled(U factor) const;
};

template<typename T>
template<typename U> requires Numeric<U>
T OutOfLineBox<T>::scaled(U factor) const { return value * (T)factor; }

// Primary class template plus a structural partial specialization (T -> T*) whose template head additionally carries
// a requires-clause.  SWIG's partial spec matcher selects on the structural pattern alone; the requires-clause is
// captured but not evaluated.  The two specs wrap as distinct types with their own method sets - primary_method only
// reaches Storage<int>, partial_method only reaches Storage<int*>.
//
// Limitation: SWIG does not select between candidates whose structural template-argument patterns are identical and
// which differ only by a requires-clause, e.g.
//
//   template<typename T>                     struct S { ... };     // primary
//   template<typename T> requires Numeric<T> struct S<T> { ... };  // concept only "partial spec"
//
// SWIG sees both as 'S<T>' and the last declared candidate wins for every instantiation; C++20 constraint
// subsumption is not modelled.  Use a structural pattern to differentiate (T vs T*, T const&, etc.) when partial
// specs need to be wrapped distinctly.
template<typename T>
struct Storage {
  int kind() const { return 1; }
  int primary_method() const { return 100; }
};

template<typename T> requires Numeric<T>
struct Storage<T*> {
  int kind() const { return 2; }
  int partial_method() const { return 200; }
};

// Concept constrained CRTP - the base class is the constrained template parameter, so the prefix
// requires-clause sits between the template head and a base list that names that parameter.  Verifies
// the constraint does not interfere with the inheritance / base list path.
template<typename T>
concept HasDraw = requires(T t) { t.draw(); };

struct Drawable {
  int counter = 0;
  void draw() { ++counter; }
};

template<typename Derived> requires HasDraw<Derived>
class View : public Derived {
public:
  void render() { this->draw(); this->draw(); }
};
%}

%template(NumericBoxInt)    NumericBox<int>;
%template(NumericBoxDouble) NumericBox<double>;

%template(HolderInt)        Holder<int>;
%template(HolderDouble)     Holder<double>;

%template(SmallBoxInt)      SmallBox<int>;

%template(CheckedBoxInt)    CheckedBox<int>;
%template(CheckedBoxDouble) CheckedBox<double>;

%template(OutOfLineBoxInt)  OutOfLineBox<int>;

%template(StorageInt)       Storage<int>;
%template(StorageIntPtr)    Storage<int*>;

%template(ViewDrawable)     View<Drawable>;
