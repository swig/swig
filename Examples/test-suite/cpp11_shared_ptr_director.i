%module(directors="1") "cpp11_shared_ptr_director"

%{
#include <memory>
%}

%include "std_shared_ptr.i";
%shared_ptr(C);
%feature("director") Base;

%inline %{
struct C {
  C() : m(1) {};
  C(int n) : m(n) {};
  int get_m() { return m; };
  int m;
};

struct Base {
  Base() {};
  virtual std::shared_ptr<C> ret_c_shared_ptr() = 0;
  virtual C ret_c_by_value() = 0;
  virtual int take_c_by_value(C c) = 0;
  virtual int take_c_shared_ptr_by_value(std::shared_ptr<C> c) = 0;
  virtual int take_c_shared_ptr_by_ref(std::shared_ptr<C>& c) = 0;
  virtual ~Base() {}
};

int call_ret_c_shared_ptr(Base* b) {
  std::shared_ptr<C> ptr = b->ret_c_shared_ptr();
  if (ptr) {
    return ptr->get_m();
  } else {
    return -1;
  }
}

int call_ret_c_by_value(Base* b) {
  C c = b->ret_c_by_value();
  return c.get_m();
}

int call_take_c_by_value(Base* b) {
  C c(5);
  return b->take_c_by_value(c);
}

int call_take_c_shared_ptr_by_value(Base* b) {
  std::shared_ptr<C> ptr(new C(6));
  return b->take_c_shared_ptr_by_value(ptr);
}

int call_take_c_shared_ptr_by_ref(Base* b) {
  std::shared_ptr<C> ptr(new C(7));
  return b->take_c_shared_ptr_by_ref(ptr);
}

%}
