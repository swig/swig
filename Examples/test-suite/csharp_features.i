%module csharp_features

// SWIG gets the method modifiers wrong occasionally, like with private inheritance, %csmethodmodifiers can fix this
%csmethodmodifiers Derived::VirtualMethod() "public virtual"
%csmethodmodifiers MoreDerived::variable "public new"

%inline %{
class Base {
public:
  virtual ~Base() {}
  virtual void VirtualMethod() {}
};
class Derived : private Base {
public:
  virtual void VirtualMethod() {}
  int variable;
};
class MoreDerived : public Derived {
public:
  int variable;
};
%}

