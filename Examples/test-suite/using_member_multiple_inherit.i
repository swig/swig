%module(ruby_minherit="1") using_member_multiple_inherit

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) MultMiddleA; /* C#, D, Java, PHP multiple inheritance */
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) MultMiddleB; /* C#, D, Java, PHP multiple inheritance */


%inline %{
// Single inheritance three deep, only using declarations
struct Susing1 {
protected:
  void usingmethod(int i) {}
};
struct Susing2 : Susing1 {
protected:
  using Susing1::usingmethod;
};
struct Susing3 : Susing2 {
  using Susing2::usingmethod;
};

// Single inheritance three deep, overload using and methods
struct Using1 {
protected:
  void usingmethod(int i) {}
};
struct Using2 : Using1 {
protected:
  // method declaration before using declaration
  void usingmethod(int i, int j) {}
  using Using1::usingmethod;
};
struct Using3 : Using2 {
  void usingmethod(int i, int j, int k) {}
  using Using2::usingmethod;
};

struct Musing2 : Using1 {
protected:
  // using declaration before method declaration
  using Using1::usingmethod;
  void usingmethod(int i, int j) {}
};
struct Musing3 : Musing2 {
  using Musing2::usingmethod;
  void usingmethod(int i, int j, int k) {}
};

struct Dusing2 : Using1 {
protected:
  using Using1::usingmethod;
  void usingmethod(int i, int j) {}
};
struct Dusing3 : Dusing2 {
  // redundant using declarations
  using Using1::usingmethod;
  using Dusing2::usingmethod;
};

// Multiple inheritance, multiple using declarations
struct Mult1 {
protected:
  void multmethod(int i) {}
};
struct Mult2 {
protected:
  void multmethod(const char *c) {}
};
struct MultMiddleA : Mult1, Mult2 {
public: // Note!
  void multmethod(int i, int j) {}
  using Mult1::multmethod;
  using Mult2::multmethod;
};
#if !defined(SWIGD) // TODO: Fix bug adding incorrect override
struct MultBottomA : MultMiddleA {
  void multmethod(int i, int j, int k) {}
  using MultMiddleA::multmethod;
};
#endif
void cplusplus_testA() {
  MultMiddleA m;
  m.multmethod(123);
  m.multmethod("hi");
  m.multmethod(123, 234);
}
struct MultMiddleB : Mult1, Mult2 {
protected: // Note!
  void multmethod(int i, int j) {}
  using Mult1::multmethod;
  using Mult2::multmethod;
};
struct MultBottomB : MultMiddleB {
  void multmethod(int i, int j, int k) {}
  using MultMiddleB::multmethod;
};
void cplusplus_testB() {
  MultBottomB m;
  m.multmethod(123);
  m.multmethod("hi");
  m.multmethod(123, 234);
  m.multmethod(123, 345, 567);
}

// Multiple inheritance, with no override on parent class. 
// This checks a corner case with fvirtual and using
// See #2872
class Vusing {
public:
  virtual void usingmethod(int i) {}
  virtual ~Vusing() {};
};
class Vusing1 : public Vusing {
public:
  virtual void usingmethod(int i) {}
  virtual ~Vusing1() {};
};
class Vusing2 : public Vusing1 {
public:
  virtual ~Vusing2() {};
  using Vusing1::usingmethod;
  virtual void usingmethod(const char* c) {};
};

/* TODO: fix when using declaration is declared before method, for example change MultMiddleA to:
struct MultMiddleB : Mult1, Mult2 {
protected: // Note!
  using Mult1::multmethod;
  using Mult2::multmethod;
  void multmethod(int i, int j) {}
};
*/
%}
