/* director.swg -- wasm-js director runtime.

   Inserted into the generated wrapper via '%insert("director")' /
   '%insert("director_h")' file slots, and into the runtime header
   chain so generated SwigDirector_<C> classes can compile.

   Differs from Lib/matlab/director.swg: no SwigStorage hashmap.
   JS values reach C++ through Embind's EM_VAL handle (an i32 index
   into the JS value table), which IS a stable reference.  So the
   Director base class just holds the handle and balances incref/
   decref against the underlying _emval_* refcount. */

#ifndef SWIG_DIRECTOR_WASMJS_HEADER_
#define SWIG_DIRECTOR_WASMJS_HEADER_

#include <emscripten/val.h>
#include <string>
#include <exception>

/* SWIG-language hooks the generated classDirector* code uses. */
#define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)
#define SWIG_DIRECTOR_RGTR(ARG1, ARG2)  /* no-op: no global registry */

namespace Swig {

  /* Base class.  Every generated SwigDirector_<C> inherits from this
     plus the user's C++ class.  Holds the JS-side proxy as an EM_VAL
     so virtual-method overrides can dispatch back. */
  class Director {
  private:
    emscripten::EM_VAL js_self_;

  public:
    Director(emscripten::EM_VAL js_self) : js_self_(js_self) {
      /* Incref so the JS proxy stays alive at least as long as the
         C++ director.  The handle was passed in via val::as<EM_VAL>()
         on the JS-side, which already took ownership of one ref --
         we incref a second time to balance our own destructor's
         decref. */
      if (js_self_) emscripten::internal::_emval_incref(js_self_);
    }

    virtual ~Director() {
      if (js_self_) emscripten::internal::_emval_decref(js_self_);
    }

    /* Recover an owned val for invoking JS methods.  Caller gets a
       fresh refcount; the val's destructor decrefs.  Our own
       js_self_ keeps its incref independently. */
    emscripten::val swig_get_self() const {
      if (!js_self_) return emscripten::val::undefined();
      emscripten::internal::_emval_incref(js_self_);
      return emscripten::val::take_ownership(js_self_);
    }

    /* MATLAB-compat shims so default Language::classDirector* output
       compiles even when we don't use these features. */
    void swig_disown() const {}
    void swig_incref() const {}

    virtual bool swig_get_inner(const char * /*name*/) const { return true; }
    virtual void swig_set_inner(const char * /*name*/, bool /*val*/) const {}
  };

  /* Exception hierarchy used by generated director-method bodies. */
  class DirectorException : public std::exception {
  protected:
    std::string swig_msg_;
  public:
    DirectorException(const char *hdr = "", const char *msg = "")
      : swig_msg_(hdr) {
      if (msg && msg[0]) { swig_msg_ += " "; swig_msg_ += msg; }
    }
    virtual ~DirectorException() throw() {}
    const char *what() const throw() { return swig_msg_.c_str(); }
    static void raise(const char *msg) { throw DirectorException("SWIG:DirectorRuntimeError", msg); }
  };

  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(const char *msg = "")
      : DirectorException("SWIG director type mismatch", msg) {}
    static void raise(const char *msg) { throw DirectorTypeMismatchException(msg); }
    static void raise(const char * /*error*/, const char *msg) { raise(msg); }
  };

  class DirectorMethodException : public DirectorException {
  public:
    DirectorMethodException(const char *msg = "")
      : DirectorException("SWIG director method error", msg) {}
    static void raise(const char *msg) { throw DirectorMethodException(msg); }
  };

  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException("SWIG director pure virtual method called", msg) {}
    static void raise(const char *msg) { throw DirectorPureVirtualException(msg); }
  };

}  /* namespace Swig */

#endif  /* SWIG_DIRECTOR_WASMJS_HEADER_ */
