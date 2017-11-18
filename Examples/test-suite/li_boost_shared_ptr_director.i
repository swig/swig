%module(directors="1") "li_boost_shared_ptr_director"

%{
#include <boost/shared_ptr.hpp>
%}

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGR)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%include <boost_shared_ptr.i>
%shared_ptr(C);
%feature("director") Base;

%inline %{
struct C {
  C() : m(1) {}
  C(int n) : m(n) {}
  int get_m() { return m; }
private:
  int m;
};

struct Base {
  Base() {}
  virtual boost::shared_ptr<C> ret_c_shared_ptr() = 0;
  virtual C ret_c_by_value() = 0;
  virtual int take_c_by_value(C c) = 0;
  virtual int take_c_by_ref(C& c) = 0;
  virtual int take_c_by_pointer(C* c) = 0;
  virtual int take_c_by_pointer_ref(C*const& c) = 0;
  virtual int take_c_shared_ptr_by_value(boost::shared_ptr<C> c) = 0;
  virtual int take_c_shared_ptr_by_ref(boost::shared_ptr<C>& c) = 0;
  virtual int take_c_shared_ptr_by_pointer(boost::shared_ptr<C>* c) = 0;
  virtual int take_c_shared_ptr_by_pointer_ref(boost::shared_ptr<C>*const&c) = 0;
  virtual int take_many_args(
    C v1, C v2,
    C &r1, C &r2,
    C *p1, C *p2,
    C *const& cr1, C *const& cr2,
    boost::shared_ptr<C> sv1, boost::shared_ptr<C> sv2,
    boost::shared_ptr<C> &sr1, boost::shared_ptr<C> &sr2,
    boost::shared_ptr<C> *sp1, boost::shared_ptr<C> *sp2,
    boost::shared_ptr<C> *const& spr1, boost::shared_ptr<C> *const& spr2
  ) = 0;
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

int call_take_c_by_ref(Base* b) {
  C c(6);
  return b->take_c_by_ref(c);
}

int call_take_c_by_pointer(Base* b) {
  C c(7);
  return b->take_c_by_pointer(&c);
}

int call_take_c_by_pointer_ref(Base* b) {
  C c(8);
  C* p(&c);
  return b->take_c_by_pointer_ref(p);
}

int call_take_c_by_pointer_with_null(Base* b) {
  C* p = NULL;
  return b->take_c_by_pointer(p);
}

int call_take_c_by_pointer_ref_with_null(Base* b) {
  C* p = NULL;
  return b->take_c_by_pointer_ref(p);
}

int call_take_c_shared_ptr_by_value(Base* b) {
  boost::shared_ptr<C> ptr(new C(9));
  return b->take_c_shared_ptr_by_value(ptr);
}

int call_take_c_shared_ptr_by_value_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_value(ptr);
}

int call_take_c_shared_ptr_by_ref(Base* b) {
  boost::shared_ptr<C> ptr(new C(10));
  return b->take_c_shared_ptr_by_ref(ptr);
}

int call_take_c_shared_ptr_by_ref_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_ref(ptr);
}

int call_take_c_shared_ptr_by_pointer(Base* b) {
  boost::shared_ptr<C> ptr(new C(11));
  return b->take_c_shared_ptr_by_pointer(&ptr);
}

int call_take_c_shared_ptr_by_pointer_with_null(Base* b) {
  boost::shared_ptr<C> ptr;
  return b->take_c_shared_ptr_by_pointer(&ptr);
}

int call_take_c_shared_ptr_by_pointer_ref(Base* b) {
  boost::shared_ptr<C> *ptr = new boost::shared_ptr<C>(new C(12));
  return b->take_c_shared_ptr_by_pointer_ref(ptr);
}

int call_take_c_shared_ptr_by_pointer_ref_with_null(Base* b) {
  boost::shared_ptr<C> *ptr = new boost::shared_ptr<C>();
  return b->take_c_shared_ptr_by_pointer_ref(ptr);
}

%}

#endif
