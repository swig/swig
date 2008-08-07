%module inherit_same_name3

%rename (xyz) C::xyz2;
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
