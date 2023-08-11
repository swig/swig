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
// Single inheritance three deep, overload using and methods
struct Using1 {
protected:
  void usingmethod(int i) {}
};
struct Using2 : Using1 {
protected:
  void usingmethod(int i, int j) {}
  using Using1::usingmethod;
};
struct Using3 : Using2 {
  void usingmethod(int i, int j, int k) {}
  using Using2::usingmethod;
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

/* TODO: fix when using declaration is declared before method, for example change MultMiddleA to:
struct MultMiddleB : Mult1, Mult2 {
protected: // Note!
  using Mult1::multmethod;
  using Mult2::multmethod;
  void multmethod(int i, int j) {}
};
*/
%}
