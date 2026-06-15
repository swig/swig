%module cpp11_inheriting_constructors_typedef

// Inheriting constructors (using Base::Base;) where the base class is named through a typedef,
// in more involved combinations: a plain non-template base via a plain typedef (with an overloaded
// constructor and a method through the same typedef), several typedef'd bases each contributing an
// inheriting-constructor using-declaration, a multi-level typedef chain, and a cross-namespace
// typedef.  Each base constructor stores a seed reported by an observable method so the inherited
// constructor is verified from the target language.  See issue #2951.

// MultiTypedefBases has two base classes; suppress the per target multiple inheritance notes.
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) MultiTypedefBases;

%inline %{
// A plain (non-template) base inherited through a plain typedef.  The base has an overloaded
// constructor and a method, both brought into the derived class through the same typedef.
struct Plain {
  int seed;
  Plain() : seed(0) {}
  Plain(int s) : seed(s) {}
  Plain(int s, int t) : seed(s + t) {}
  int value() const { return seed; }
};
struct PlainTypedefBase : Plain {
  typedef Plain base_type;
  using base_type::base_type;   // inherit Plain(int) and Plain(int, int) through the typedef
  using base_type::value;       // inherit value() through the same typedef
};
%}

%inline %{
// Two base classes, each named through its own typedef, each contributing an inheriting-constructor
// using-declaration.  The two bases' inherited methods make each base observable.
struct AlphaBase {
  int a;
  AlphaBase() : a(0) {}
  AlphaBase(int x) : a(x) {}
  int alpha() const { return a; }
};
struct BetaBase {
  int b;
  BetaBase() : b(0) {}
  BetaBase(int x, int y) : b(x * y) {}
  int beta() const { return b; }
};
struct MultiTypedefBases : AlphaBase, BetaBase {
  typedef AlphaBase a_type;
  typedef BetaBase b_type;
  using a_type::a_type;   // inherit AlphaBase(int)
  using b_type::b_type;   // inherit BetaBase(int, int)
  using a_type::alpha;
  using b_type::beta;
};
%}

%inline %{
// A multi-level typedef chain naming the base: resolving the using-declaration qualifier to the
// base class requires following the whole chain.
struct ChainBase {
  int seed;
  ChainBase() : seed(0) {}
  ChainBase(int s) : seed(s) {}
  int value() const { return seed; }
};
struct DeepTypedefChain : ChainBase {
  typedef ChainBase alias1;
  typedef alias1 alias2;
  typedef alias2 base_type;
  using base_type::base_type;
};
%}

%inline %{
// The base lives in one namespace and is named through a typedef declared in another namespace.
namespace nsA {
struct NsABase {
  int seed;
  NsABase() : seed(0) {}
  NsABase(int s) : seed(s) {}
  int value() const { return seed; }
};
}
namespace nsB {
typedef nsA::NsABase Exported;
}
struct CrossNsTypedef : nsA::NsABase {
  typedef nsB::Exported base_type;
  using base_type::base_type;
};
%}
