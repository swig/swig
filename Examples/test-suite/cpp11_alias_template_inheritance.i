%module cpp11_alias_template_inheritance

// C++11 alias templates used in inheritance positions.  cpp11_alias_templates only uses alias
// templates as function return types; this exercises an alias template instantiation as:
//   - a base class, with a member imported by a using-declaration through the alias qualifier
//   - a base class whose inherited enum is imported through the alias qualifier, with the alias also
//     naming a function parameter type
//   - the base of a class template, where the using-declaration imports an overload that merges
//     with a locally declared overload
//   - an inheriting-constructor scope qualifier
// As documented for alias templates, each alias instantiation is registered with an empty
// %template() so it resolves wherever the underlying instantiation would.  'XIdentity',
// 'PaletteIdentity' and 'BaseCIdentity' are identity alias templates ('template <class T> using ... =
// T;'); 'AdderAlias' aliases an actual template instantiation ('Adder<T>').

%inline %{
struct X {
  int m() { return 11; }
};

// Identity alias template naming the base, used as a base and a using-declaration scope qualifier.
template <class T> using XIdentity = T;

struct DerivedX : XIdentity<X> {
  using XIdentity<X>::m;
};

struct Palette {
  enum Color { RED, GREEN, BLUE };
};

// Identity alias naming the enum's base, used as a base, a using-declaration qualifier importing the
// inherited enum, and a function parameter type.
template <class T> using PaletteIdentity = T;

struct DerivedPalette : PaletteIdentity<Palette> {
  using PaletteIdentity<Palette>::Color;
};

int palette_to_int(PaletteIdentity<Palette>::Color c) { return (int)c; }

template <class T> struct Adder {
  T add(T a, T b) { return a + b; }
};

// Alias template renaming the underlying template instantiation.
template <class T> using AdderAlias = Adder<T>;

template <class D> struct AliasCalc : AdderAlias<D> {
  int add(int a) { return a + 100; } // local single-arg overload
  using AdderAlias<D>::add;          // imports add(D, D) through the alias qualifier; merges
};
%}

%template() XIdentity<X>;            // register the alias instantiation used as DerivedX's base
%template() PaletteIdentity<Palette>; // register the alias instantiation used as DerivedPalette's base
%template(AdderInt) Adder<int>;
%template() AdderAlias<int>;         // register the alias instantiation used as AliasCalc's base
%template(AliasCalcInt) AliasCalc<int>;

// Inheriting constructor where the base is named through an identity alias template.  The
// %template() registration must precede the derived class so the inherited constructor recognises
// the alias instantiation as a base.
%inline %{
struct BaseC {
  int value;
  BaseC(int v) : value(v) {}
};

template <class T> using BaseCIdentity = T;
%}

%template() BaseCIdentity<BaseC>;    // register the alias instantiation used as DerivedC's base

%inline %{
struct DerivedC : BaseCIdentity<BaseC> {
  using BaseCIdentity<BaseC>::BaseCIdentity;
};
%}
