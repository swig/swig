%module cpp11_inheriting_constructors_typedef

// Inheriting constructors where the base class is named through a typedef, in various forms.  Each base
// constructor stores a seed reported by an observable method so the inherited constructor is verified
// from the target language.  See issue #2951.

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) MultiDerived;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) OverflowGuard;

#ifdef SWIGD
%ignore BaseB::valueb; // D single inheritance: avoids an 'override' with no matching base
#endif

%include <std_string.i>

%inline %{
#include <string>
// Base has a member typedef of itself (BaseStruct); BaseClass is a typedef for Base in the enclosing
// scope.  An inheriting constructor can name Base through either typedef, with the unqualified-id being
// the typedef name or Base's own name.
class Base {
protected:
  int seed;
  int protectedvalue() const { return seed; }
public:
  typedef Base BaseStruct;
  Base() : seed(0) {}
  Base(int s) : seed(s) {}
  virtual ~Base() {}
  int value() const { return seed; }
};
typedef Base BaseClass;

struct Derived1 : Base {
  using BaseClass::BaseClass;
};
struct Derived2 : Base {
  using BaseStruct::BaseStruct;
};
struct Derived3 : Base {
  using BaseStruct::Base;       // unqualified-id is Base's own name
};
struct Derived4 : Base {
  using Base::Base;
};
struct ImportMember : Base {
  // Brings a base member into scope, not a constructor.  The std::string constructor confirms the base
  // int constructor is not inherited.
  ImportMember(std::string s) : Base((int)s.size()) {}
  using Base::BaseStruct;
  using Base::protectedvalue;
};
%}

%inline %{
// Overloaded base constructor and a method inherited through a typedef in the derived class.
struct OverloadBase {
  int seed;
  OverloadBase() : seed(0) {}
  OverloadBase(int s) : seed(s) {}
  OverloadBase(int s, int t) : seed(s + t) {}
  int overloadvalue() const { return seed; }
};
struct OverloadDerived : OverloadBase {
  typedef OverloadBase base_type;
  using base_type::base_type;
  using base_type::overloadvalue;
};
%}

%inline %{
// Two typedef'd bases, an inheriting constructor from each.
struct BaseA {
  int a;
  BaseA() : a(0) {}
  BaseA(int x) : a(x) {}
  int valuea() const { return a; }
};
struct BaseB {
  int b;
  BaseB() : b(0) {}
  BaseB(int x, int y) : b(x * y) {}
  int valueb() const { return b; }
};
struct MultiDerived : BaseA, BaseB {
  typedef BaseA a_type;
  typedef BaseB b_type;
  using a_type::a_type;
  using b_type::b_type;
  using a_type::valuea;
  using b_type::valueb;
};
%}

%inline %{
// Base named through a multi-level typedef chain.
struct ChainBase {
  int seed;
  ChainBase() : seed(0) {}
  ChainBase(int s) : seed(s) {}
  int chainvalue() const { return seed; }
};
struct ChainDerived : ChainBase {
  typedef ChainBase chain1;
  typedef chain1 chain2;
  typedef chain2 base_type;
  using base_type::base_type;
};
%}

%inline %{
// Base in one namespace named through a typedef in another namespace.
namespace ns1 {
struct NsBase {
  int seed;
  NsBase() : seed(0) {}
  NsBase(int s) : seed(s) {}
  int nsvalue() const { return seed; }
};
}
namespace ns2 {
typedef ns1::NsBase NsAlias;
}
struct NsDerived : ns1::NsBase {
  typedef ns2::NsAlias base_type;
  using base_type::base_type;
};
%}

%inline %{
// Over-flag guard: using First::Second imports First's method Second (named like the other base Second),
// not a constructor.
struct Second {
  int s;
  Second() : s(0) {}
  Second(int x) : s(x) {}
  int secondvalue() const { return s; }
};
struct First {
  int Second(int x) const { return x * 10; }
};
struct OverflowGuard : First, Second {
  using First::Second;
};
%}
