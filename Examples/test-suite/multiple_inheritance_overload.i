%module(ruby_minherit="1") multiple_inheritance_overload

%warnfilter(SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE); /* languages not supporting multiple inheritance */

#if defined(SWIGJAVA) || defined(SWIGCSHARP)
%include <swiginterface.i>
%interface_impl(Space::Base);
%interface_impl(Space::AnotherBase);
#endif

%ignore AnotherSpace::AnotherBase::AnotherMethod(int i) const;
%ignore Space::Base::Method(int i) const;
%ignore Space::Base::NotVirtualMethod(int i) const;
%ignore Space::Base::SimilarOverloadedMethod(unsigned short i);
%rename(MethodForRenamingConst) Space::Base::MethodForRenaming(int i) const;

// Different overloaded warning filters needed for scripting languages (eg Python) and for statically typed languages (eg C#).
%warnfilter(509, 516) Space::Base::MethodWarningSuppressed(int i) const;

%inline %{
namespace AnotherSpace {
class AnotherBase {
public:
  virtual int AnotherMethod(int i) { return 0; }
  virtual int AnotherMethod(int i) const { return 1; }
  virtual ~AnotherBase() {}
};
}

namespace Space {
class Base
{
public:
  virtual int Method(int i) { return 0; }
  virtual int Method(int i) const { return 1; }
  virtual int MethodForRenaming(int i) { return 0; }
  virtual int MethodForRenaming(int i) const { return 1; }
  virtual int MethodWarningSuppressed(int i) { return 0; }
  virtual int MethodWarningSuppressed(int i) const { return 1; }
  int NotVirtualMethod(int i) { return 0; }
  int NotVirtualMethod(int i) const { return 1; }

  typedef int Integer;

  // int and unsigned short are wrapped with a Java int and so would be automatically ignored with a warning
  virtual int SimilarOverloadedMethod(Integer i) { return 0; }
  virtual int SimilarOverloadedMethod(unsigned short i) { return 1; }
  virtual ~Base() {}
  static Base *in_out(Base *p) { return p; }
};

class Derived : public Base, public AnotherSpace::AnotherBase
{
public:
  int member_var;
};
class MoreDerived : public Derived {
};
}

namespace OtherSpace {
class OtherDerived : public Space::Base
{
};
}
%}
