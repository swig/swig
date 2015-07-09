/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes that proxy
 * method calls from C++ to ObjC extensions.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include "components/Director.h"
#include "utils/Log.h"

#if defined(DEBUG_DIRECTOR_OWNED)
#include <iostream>
#endif
#include <mutex>
#include <atomic>

namespace Swig {

  /* director base class */
  class Director : public Nuti::Director {
  protected:
    __weak id swig_weak_ptr_;
    id swig_strong_ptr_;
    std::atomic<int> swig_refcounter_;
    mutable std::recursive_mutex swig_director_mutex_;

  public:
    Director() : swig_weak_ptr_(nil), swig_strong_ptr_(nil), swig_refcounter_(0), swig_director_mutex_() {
    }

    virtual ~Director() {
    }

    // Swig methods

    void swig_set_self(id obj) {
      std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
      if (swig_strong_ptr_) {
        swig_strong_ptr_ = obj;
      }
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

    // Nutiteq-specific methods

    virtual void retainDirector() {
      int counter = swig_refcounter_.fetch_add(1);
      if (counter == 0) {
        std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
        swig_objc_change_ownership(swig_weak_ptr_, false);
      }
    }

    virtual void releaseDirector() {
      int counter = swig_refcounter_.fetch_sub(1) - 1;
      if (counter == 0) {
        std::lock_guard<std::recursive_mutex> lock(swig_director_mutex_);
        swig_objc_change_ownership(swig_weak_ptr_, true);
      } else if (counter < 0) {
        Nuti::Log::Errorf("Director::release: Reference counter = %d!", counter);
      }
    }

    virtual void* getDirectorObject() const {
      id self = swig_get_self();
      return self ? (void *) CFBridgingRetain(self) : 0;
    }
  };
}

#endif /* __cplusplus */
