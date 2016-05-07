%module inherit_same_name4

%ignore B;

%inline %{
class A {
  public:
  virtual int xyz(int) { return 0; }
};

class B : public A {
};

class C : public B {
  public:
  virtual int xyz(int) { return 1; }
};

%}
