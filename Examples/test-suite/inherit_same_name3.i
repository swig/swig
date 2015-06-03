%module inherit_same_name3

// In Java static methods with the same name as the base class methods are
// forbidden, so renaming C::xyz2 would result in compilation methods in the
// generated code (it would have been better if it resulted in SWIG errors...).
#ifndef SWIGJAVA
%rename (xyz) C::xyz2;
#endif
%rename (xyz) H::xyz2;
%ignore I::xyz(int);

%inline %{
class A {
  public:
  virtual int xyz(int) { return 1; }
};

class C : public A {
  public:
  static int xyz2(int) { return 2; }
};

class D {
  protected:
  virtual int xyz(int) { return 1; }
};

class E : public D {
  public:
  int xyz(int) { return 2; }
};

class F : public E {
  public:
  int xyz(int) { return 3; }
};

class G {
  public:
  virtual int xyz(int) { return 1; }
};

class H : public G {
  public:
  virtual int xyz2(int) { return 2; }
};

/* This is a compile test -J::xyz (renamed from J::xyz2) should have no override modifier */

class I {
  public:
  virtual int xyz(int) { return 1; }
};

class J : public I {
  public:
  virtual int xyz2(int) { return 2; }
};

%}
