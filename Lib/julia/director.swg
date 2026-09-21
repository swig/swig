/* director.swg -- Julia director runtime.
 *
 * Inserted verbatim into the generated wrapper's runtime so SwigDirector_<C>
 * classes compile.  A SwigDirector_<C> holds a jl_value_t* to the Julia
 * object the user subclassed with; each overridden virtual marshals C++ args
 * to Julia (directorin), invokes the module generic '<C>_<method>(self,
 * args...)', and marshals the Julia return back (directorout).
 *
 * The Julia self object is rooted for the director's lifetime via the
 * generated module's _swig_director_roots (an IdDict) so
 * the GC cannot reclaim it while C++ holds the pointer. */

#ifndef SWIG_DIRECTOR_JULIA_HEADER_
#define SWIG_DIRECTOR_JULIA_HEADER_

#include <julia.h>
#include <stdexcept>
#include <string>

/* Recover the Swig::Director base from a director-managed object pointer. */
#define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)

/* The Julia module that owns the generated director dispatch functions.
   Set from Julia __init__ via swig_jl_set_module(@__MODULE__). */
static jl_module_t *swig_jl_director_module = 0;
extern "C" void swig_jl_set_module(jl_value_t *m) {
  swig_jl_director_module = (jl_module_t *)m;
}

namespace Swig {
  /* Look up a director dispatch function 'name' in the registered module. */
  inline jl_value_t *swig_director_fn(const char *name) {
    jl_module_t *m = swig_jl_director_module ? swig_jl_director_module : jl_main_module;
    return jl_get_function(m, name);
  }

  /* Look up a module-scoped global (the no-override sentinel). */
  inline jl_value_t *swig_director_global(const char *name) {
    jl_module_t *m = swig_jl_director_module ? swig_jl_director_module : jl_main_module;
    return jl_get_global(m, jl_symbol(name));
  }

  /* The roots IdDict is defined Julia-side (const _swig_director_roots) in the
     director module; the GC keeps it (and its entries) reachable from there. */
  inline jl_value_t *swig_director_roots() {
    jl_module_t *m = swig_jl_director_module ? swig_jl_director_module : jl_main_module;
    return jl_get_global(m, jl_symbol("_swig_director_roots"));
  }

  /* Render the pending Julia exception (from a failed upcall) as a string, so
     the user's own error text surfaces in the C++-side error.  Uses Julia's
     'sprint(showerror, e)'; falls back to the exception type name if rendering
     itself fails.  Clears no state -- caller decides.  Returns "" if no
     exception is pending. */
  inline std::string swig_director_exception_msg() {
    jl_value_t *e = jl_exception_occurred();
    if (!e) return std::string();
    std::string msg;
    JL_GC_PUSH1(&e);
    jl_value_t *sprintf_fn = jl_get_function(jl_base_module, "sprint");
    jl_value_t *showerror_fn = jl_get_function(jl_base_module, "showerror");
    if (sprintf_fn && showerror_fn) {
      jl_value_t *s = jl_call2(sprintf_fn, (jl_value_t *)showerror_fn, e);
      if (s && jl_is_string(s)) msg = jl_string_ptr(s);
    }
    if (msg.empty()) msg = jl_typeof_str(e);  /* fallback: exception type name */
    JL_GC_POP();
    return msg;
  }

  /* Each native director gets its own root, including directors sharing a callback object. */
  class Director {
  protected:
    jl_value_t *swig_self;
  public:
    Director(jl_value_t *self) : swig_self(self) {
      if (swig_self) {
        jl_value_t *d = swig_director_roots();
        jl_value_t *key = 0;
        JL_GC_PUSH2(&d, &key);
        key = jl_box_voidpointer(this);
        jl_value_t *result = jl_call3(jl_get_function(jl_base_module, "setindex!"), d, swig_self, key);
        JL_GC_POP();
        if (!result) throw std::runtime_error("unable to retain Julia director callback");
      }
    }
    virtual ~Director() {
      if (swig_self) {
        jl_value_t *d = swig_director_roots();
        jl_value_t *key = 0;
        JL_GC_PUSH2(&d, &key);
        key = jl_box_voidpointer(this);
        jl_call2(jl_get_function(jl_base_module, "delete!"), d, key);
        JL_GC_POP();
      }
    }
    jl_value_t *swig_get_self() const { return swig_self; }
    void swig_disown() { }  /* ownership stays with the Julia proxy finalizer */
  };

  /* Thrown when a pure-virtual director method has no Julia override. */
  class DirectorPureVirtualException : public std::runtime_error {
  public:
    DirectorPureVirtualException(const char *m)
      : std::runtime_error(std::string("Attempt to invoke pure virtual method ") + m) {}
  };
}

#endif
