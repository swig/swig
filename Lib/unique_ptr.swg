/* -----------------------------------------------------------------------------
 * unique_ptr.swg
 *
 * Common std::unique_ptr support.
 * Not for direct inclusion.
 * ----------------------------------------------------------------------------- */


%fragment("SwigNoDeleteUniquePtr", "header", fragment="<memory>") {
namespace swig {
  template<typename T>
  struct NoDeleteUniquePtr {
    std::unique_ptr<T> uptr;
    NoDeleteUniquePtr(T *p = 0) : uptr(p) {}
    ~NoDeleteUniquePtr() {uptr.release();}
  };
}
}

namespace std {
  template <class T> class unique_ptr {};
}
