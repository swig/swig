%module(ruby_minherit="1") multiple_inheritance_interfaces

%warnfilter(SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE); /* languages not supporting multiple inheritance */

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include <swiginterface.i>
%interface_custom("A", "IA", IA)
%interface_custom("B", "IB", IB)
%interface_custom("%(strip:[I])s", "I%s", IC) // same as %interface_custom("C", "IC", IC)
#endif

%inline %{
struct IA {
  virtual void ia() {};
  virtual void ia(const char *s, bool b = true) {}
  virtual void ia(int i) {}
  virtual ~IA() {}
};
struct IB { virtual ~IB() {} virtual void ib() {} };
struct IC : IA, IB {};
struct D : IC {};
struct E : D {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_custom("J", "IJ", IJ)
%interface_custom("K", "IK", IK)
%interface_custom("L", "IL", IL)
#endif
%inline %{
struct IJ { virtual ~IJ() {}; virtual void ij() {} };
struct IK : IJ {};
struct IL : IK {};
struct M : IL {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_custom("Q", "IQ", IQ)
#endif
%inline %{
struct P  { virtual ~P() {}  virtual void p()  {} };
struct IQ { virtual ~IQ() {} virtual void iq() {} };
struct R : IQ, P {};
struct S : P, IQ {};
struct T : IQ {};
struct U : R {};
struct V : S {};
struct W : T {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface(IV1)
%interface(IV2)
%interface(V3)
#endif
%inline %{
struct IV1 : virtual IA {};
struct IV2 : virtual IA {};
struct V3 : IV1, IV2 {};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_impl(Undesirables);
#endif

%inline %{
// Don't put variables and enums into interface
class Undesirables
{
public:
  Undesirables() : UndesiredVariable() {}
  virtual ~Undesirables() {}
  virtual void Method(int i) = 0;

  enum UndesiredEnum { UndesiredEnum1, UndesiredEnum2 };
  static void UndesiredStaticMethod(UndesiredEnum e) {}
  int UndesiredVariable;
  static int UndesiredStaticVariable;
  static const int UndesiredStaticConstVariable = 0;
};

int Undesirables::UndesiredStaticVariable = 0;

struct UndesirablesDerived : Undesirables {
  virtual void Method(int i) {}
};
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_impl(BaseOverloaded);
#endif
%inline %{
struct BaseOverloaded {
  typedef P PTypedef;
  virtual ~BaseOverloaded() {}
  virtual void identical_overload(int i, const PTypedef &pp = PTypedef()) {}
};

struct DerivedOverloaded : public BaseOverloaded {
  virtual void identical_overload(int i, const PTypedef &p = PTypedef()) {}
};
%}


#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface(Space::X)
#endif

// Test the csinterfacemodifiers and javainterfacemodifiers typemaps.
#if defined(SWIGCSHARP)
/* change access from default "public class" to "internal class" */
%typemap(csclassmodifiers) InternalAccess "internal class"
/* The following modifiers are also needed with the above access modifier change */
%typemap(csclassmodifiers) Space::X "internal class"
%typemap(csinterfacemodifiers) Space::X "internal interface"
#elif defined(SWIGJAVA)
%typemap(javaclassmodifiers) InternalAccess "final /*notpublic*/ class"
%typemap(javaclassmodifiers) Space::X "final class"
%typemap(javainterfacemodifiers) Space::X "/*notpublic*/ interface"
#endif

%inline %{
struct InternalAccess {};
namespace Space {
  class X {
  public:
    virtual void x(const InternalAccess& date) const = 0;
    virtual ~X() {}
  };
}
%}

// Test additional interfaces - these are designed for non-C++ interfaces
#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%interface_custom("Additional1", "IAdditional1", IAdditional1)
#endif

#if defined(SWIGJAVA)
%interface_additional("Additional2", "IAdditional2", "java.util.EventListener", IAdditional2)
%interface_additional("Additional3", "IAdditional3", "java.util.EventListener", IAdditional3)
#elif defined(SWIGCSHARP)
%interface_additional("Additional2", "IAdditional2", "global::System.ICloneable", IAdditional2)
%interface_additional("Additional3", "IAdditional3", "global::System.ICloneable", IAdditional3)
%extend IAdditional2 {
%proxycode %{
  public virtual object Clone() {
    return new Additional2(this);
  }
%}
}
%extend IAdditional3 {
%proxycode %{
  public virtual object Clone() {
    return new Additional3(this);
  }
%}
}
%extend AdditionalConcrete {
%proxycode %{
  public virtual object Clone() {
    return new AdditionalConcrete(this);
  }
%}
}
#endif

%copyctor AdditionalConcrete;
%copyctor IAdditional2;
%copyctor IAdditional3;

%inline %{
struct IAdditional1 { virtual ~IAdditional1() {} };
struct IAdditional2 { virtual ~IAdditional2() {} };
struct IAdditional3 : IAdditional1, IAdditional2 {};
struct AdditionalConcrete : IAdditional1, IAdditional2 {};
%}
