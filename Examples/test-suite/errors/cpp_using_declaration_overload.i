%module xxx

struct Base {
  void m(bool) {}
};
struct Derived : Base { 
  void m(bool) const {}
  using Base::m;
};
