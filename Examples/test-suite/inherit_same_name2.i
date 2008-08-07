%module inherit_same_name2

%rename (aaa2) B::aaa();
%rename (bbb) B::bbb2();

%ignore C;

%rename (aaa2) G::aaa();

%inline %{

class A {
  public:
  int aaa() { return 0; }
  int bbb() { return 0; }
  int ccc;
};

class B : public A {
  public:
  int aaa() { return 1; }
  int bbb2() { return 1; }
  void ccc(int) {}
};

class C {
  public:
  virtual int aaa() { return 0; }
};

class D : public C {
  public:
  int aaa() { return 1; }
};

class E : public D {
  public:
  int aaa() { return 2; }
};

class F {
  public:
  virtual int aaa() { return 1; }
};

class G : public F {
  public:
  virtual int aaa() { return 2; }
};

%}
