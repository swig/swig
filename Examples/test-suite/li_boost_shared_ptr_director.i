%module(directors="1") "li_boost_shared_ptr_director"

%{
#include <boost/shared_ptr.hpp>
%}

%include "boost_shared_ptr.i";
%shared_ptr(C);
%feature("director") Base;

%inline %{
struct C {
  C() : m(1) {}
  C(int n) : m(n) {}
  int get_m() { return m; }
  int m;
};

struct Base {
  Base() {}
  virtual boost::shared_ptr<C> ret_c_shared_ptr() = 0;
  virtual C ret_c_by_value() = 0;
  virtual int take_c_by_value(C c) = 0;
  virtual int take_c_shared_ptr_by_value(boost::shared_ptr<C> c) = 0;
  virtual int take_c_shared_ptr_by_ref(boost::shared_ptr<C>& c) = 0;
  virtual int take_c_shared_ptr_by_pointer(boost::shared_ptr<C>* c) = 0;
  virtual int take_c_shared_ptr_by_pointer_ref(boost::shared_ptr<C>*const&c) = 0;
  virtual ~Base() {}
};

int call_ret_c_shared_ptr(Base* b) {
  boost::shared_ptr<C> ptr = b->ret_c_shared_ptr();
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
  boost::shared_ptr<C> ptr(new C(6));
  return b->take_c_shared_ptr_by_value(ptr);
}

int call_take_c_shared_ptr_by_value_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_value(ptr);
}

int call_take_c_shared_ptr_by_ref(Base* b) {
  boost::shared_ptr<C> ptr(new C(7));
  return b->take_c_shared_ptr_by_ref(ptr);
}

int call_take_c_shared_ptr_by_ref_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_ref(ptr);
}

int call_take_c_shared_ptr_by_pointer(Base* b) {
  boost::shared_ptr<C> ptr(new C(8));
  return b->take_c_shared_ptr_by_pointer(&ptr);
}

int call_take_c_shared_ptr_by_pointer_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_pointer(&ptr);
}

int call_take_c_shared_ptr_by_pointer_ref(Base* b) {
  boost::shared_ptr<C> *ptr = new boost::shared_ptr<C>(new C(9));
  return b->take_c_shared_ptr_by_pointer_ref(ptr);
}

int call_take_c_shared_ptr_by_pointer_ref_with_null(Base* b) {
  boost::shared_ptr<C> *ptr = new boost::shared_ptr<C>();
  return b->take_c_shared_ptr_by_pointer_ref(ptr);
}

%}
