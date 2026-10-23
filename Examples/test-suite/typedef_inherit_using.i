// Using-declaration whose scope qualifier is a self-referential typedef.
// typedef_inherit.i covers inheriting through a self-referential typedef base, but not a
// using-declaration qualified by such a typedef, nor a using-declaration qualified by a
// further typedef alias of it.
//
// This test also imports an inherited conversion operator with 'using Conv::operator int;'
// (issue #3480), which was previously a syntax error.
%module typedef_inherit_using

%rename(toInt) *::operator int;

%inline %{
struct X {
  int m() { return 11; }
  int n(int i) { return i; }
};

// Self-referential typedef ('typedef struct X X;').
typedef struct X X;

struct Derived : X {
  using X::m;
  using X::n;
};

// Extra typedef alias for the base, used as a using-declaration scope qualifier.
typedef X XAlias;

struct Derived2 : XAlias {
  using XAlias::m;
};

// Inherited conversion operator imported with a using-declaration. Private inheritance means
// the conversion operator reaches UsesConv only through the using-declaration (issue #3480).
struct Conv {
  operator int() const { return 42; }
};

struct UsesConv : private Conv {
  using Conv::operator int;
};
%}
