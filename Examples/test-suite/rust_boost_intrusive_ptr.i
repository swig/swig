%module rust_boost_intrusive_ptr

%include <boost_intrusive_ptr.i>

%{
#if defined(__has_include)
# if __has_include(<boost/intrusive_ptr.hpp>)
#include <boost/intrusive_ptr.hpp>
# else
namespace boost {
  template<class T> class intrusive_ptr {
  public:
    intrusive_ptr() : ptr(0) {
    }
    intrusive_ptr(T *ptr) : ptr(ptr) {
      if (ptr)
        intrusive_ptr_add_ref(ptr);
    }
    intrusive_ptr(const intrusive_ptr &other) : ptr(other.ptr) {
      if (ptr)
        intrusive_ptr_add_ref(ptr);
    }
    ~intrusive_ptr() {
      if (ptr)
        intrusive_ptr_release(ptr);
    }
    intrusive_ptr &operator=(const intrusive_ptr &other) {
      if (other.ptr)
        intrusive_ptr_add_ref(other.ptr);
      if (ptr)
        intrusive_ptr_release(ptr);
      ptr = other.ptr;
      return *this;
    }
    T *get() const {
      return ptr;
    }
    T *operator->() const {
      return ptr;
    }
    operator bool() const {
      return ptr != 0;
    }
  private:
    T *ptr;
  };
}
# endif
#endif
%}

%inline %{
struct RustBoostIntrusiveThing {
  RustBoostIntrusiveThing() : refs(0), value(0) {
  }
  RustBoostIntrusiveThing(int value) : refs(0), value(value) {
  }
  int refs;
  int value;
};

inline void intrusive_ptr_add_ref(RustBoostIntrusiveThing *thing) {
  ++thing->refs;
}

inline void intrusive_ptr_release(RustBoostIntrusiveThing *thing) {
  if (--thing->refs == 0)
    delete thing;
}
%}

%intrusive_ptr(RustBoostIntrusiveThing)

%inline %{
boost::intrusive_ptr<RustBoostIntrusiveThing> rust_make_boost_intrusive_thing(int value) {
  return boost::intrusive_ptr<RustBoostIntrusiveThing>(new RustBoostIntrusiveThing(value));
}

int rust_boost_intrusive_thing_value(boost::intrusive_ptr<RustBoostIntrusiveThing> thing) {
  return thing ? thing->value : -1;
}
%}
