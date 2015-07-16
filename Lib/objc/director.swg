/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to ObjC extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#if defined(DEBUG_DIRECTOR_OWNED)
#include <iostream>
#endif

namespace Swig {

  /* director base class */
  class Director {
  protected:
    __weak id swig_weak_ptr_;
    id swig_strong_ptr_;

  public:
    Director() : swig_weak_ptr_(nil), swig_strong_ptr_(nil) {
    }

    virtual ~Director() {
    }

    // Swig methods

    void swig_set_self(id obj) {
      if (swig_strong_ptr_) {
        swig_strong_ptr_ = obj;
      }
      swig_weak_ptr_ = obj;
    }

    id swig_get_self() const {
      return swig_weak_ptr_;
    }

    void swig_objc_change_ownership(id obj, bool take_or_release) {
      swig_strong_ptr_ = take_or_release ? nil : obj;
    }

  };
}

#endif /* __cplusplus */
