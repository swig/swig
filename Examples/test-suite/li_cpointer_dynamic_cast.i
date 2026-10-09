%module li_cpointer_dynamic_cast

%include "cpointer.i"

%inline %{
struct Base {
  virtual ~Base() {}
  virtual int val1() { return 1; }
  int val2() { return 2; }
};
struct Derived : Base {
  virtual ~Derived() {}
  virtual int val1() { return 11; }
  int val2() { return 12; }
  static Base* NewDerived() { return new Derived; }
};
struct Other : Base {
  virtual ~Other() {}
  virtual int val1() { return 21; }
  int val2() { return 22; }
  static Base* NewOther() { return new Other; }
};
%}

%pointer_cast(Base*,Derived*,staticDerivedCast);
%pointer_dynamic_cast(Base*,Derived*,dynDerivedCast);
%pointer_cast(Base*,Other*,staticOtherCast);
%pointer_dynamic_cast(Base*,Other*,dynOtherCast);
