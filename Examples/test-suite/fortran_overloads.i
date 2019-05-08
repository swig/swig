%module fortran_overloads

%inline %{

class Base {
public:
 int func() { return 0; }
 int func(int a) { return a; }
 virtual int func(int a, int b) { return a + b; }
 void func(int, int, int) {} // !! Can't overload subroutine with functions
 void sub(int *x) { *x = 123; }
};

class DerivedOverloads : public Base {
 public:
  double func(double, double) {return 1.0;}
  virtual int func(int x, int y) { return x - y; } // !! different parameter names
  void sub(int *x) { *x = 456; } // overrides, won't apply if called as base class
};

class DerivedDerived : public DerivedOverloads {
  virtual int func(int a, int b) { return a + a - b; }
};

Base* base_ptr(Base* b) {
  return b;
}

class DerivedUsing : public Base {
 public:
  using Base::func; // !! Generates functions ambiguous with base class
  double func(double b) { return b; }
};

class DerivedNotGeneric : public Base {
 public:
  double func(double b) { return b; } // !! Must be labeled as generic
  void sub(int) { } // !! Generic in daughter class but not in parent
  void sub(double) {  } // !! Generic in daughter class but not in parent
};

class LowercaseIssues : public Base {
 public:
  int fUnC() { return 2; }
  int funC(int) { return 3; }
};

%}
