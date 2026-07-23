%module using_member_typedef_overload

// Members imported into a derived class by a using-declaration whose scope qualifier is a typedef.
// using_member_typedef imports a single member through a typedef qualifier; this adds two cases that
// were otherwise untested:
//   - an overload imported through a typedef-to-template-instantiation qualifier that merges with an
//     overload declared locally in the derived class (without a spurious Warning 526)
//   - an unscoped enum inherited through a using-declaration whose qualifier is a typedef for the
//     base, with that same typedef also naming a function parameter type

%inline %{
template <class T> struct Adder {
  T add(T a, T b) { return a + b; }
};

template <class D> struct Calc : Adder<D> {
  typedef Adder<D> Base;              // typedef to the template instantiation
  int add(int a) { return a + 100; }  // local single-arg overload
  using Base::add;                    // imports the two-arg add(D, D); merges with the local overload
};

struct Colours {
  enum Color { RED, GREEN, BLUE };
};
typedef Colours ColoursAlias;

struct DerivedColours : ColoursAlias {
  using ColoursAlias::Color;          // imports the inherited enum through the typedef qualifier
};

int to_int(ColoursAlias::Color c) { return (int)c; } // typedef qualifier in a function signature
%}

%template(AdderInt) Adder<int>;
%template(CalcInt) Calc<int>;
