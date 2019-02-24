%module(directors="1") cpp11_final_directors

%director Derived;

%inline %{
struct Base {
  virtual void basemeth() final {}
  virtual ~Base() {}
};

struct Derived : Base {
  virtual int derivedmeth() final { return 1; }
  virtual int meth() { return 2; }
  virtual ~Derived() {}
};
%}
