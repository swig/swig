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
#include <mutex>

namespace Swig {

  /* director base class */
  class Director {

  protected:
    __weak id swig_weak_ptr_;
    id swig_strong_ptr_;
    mutable std::recursive_mutex swig_director_mutex_;

  public:
    Director() : swig_weak_ptr_(nil), swig_strong_ptr_(nil), swig_director_mutex_() {
    }

    virtual ~Director() {
    }

    void swig_set_self(id obj) {
        std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
        swig_weak_ptr_ = obj;
    }

    id swig_get_self() const {
        std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
        return swig_weak_ptr_;
    }

    void swig_objc_change_ownership(id obj, bool take_or_release) {
        std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
        swig_strong_ptr_ = take_or_release ? nil : obj;
    }

  };
}

#endif /* __cplusplus */

