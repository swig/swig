/* WebAssembly runtime support for JavaScript value handles and SWIG proxies.
   Wrapped objects cross the wasm boundary as EM_VAL handles. Their '_ptr'
   stores the native address, and '_swig_type' identifies the SWIG type for
   checked pointer conversion and inheritance adjustment. Registered class
   factories create owning or borrowed proxies for native results. */

#include <emscripten/val.h>
#include <emscripten/bind.h>
#include <cmath>
#include <limits>
#include <type_traits>

/* EM_VAL is the JavaScript value handle used by the generated wrappers. */
using emscripten::EM_VAL;

/* Thread-local-ish error slot.  wasm-js is single-threaded today, so
   plain statics suffice.  Every generated wrapper emits a 'fail:' label
   that SWIG_fail / SWIG_exception_fail goto; the wrapper returns its
   zero-initialised sentinel ('_ret', 0 / null EM_VAL / null pointer) on
   that path.  The JS side reads '_swig_last_error_*' after each call
   to surface the failure. */
static int  SWIG_lasterror_code = 0;
static char SWIG_lasterror_msg[256] = "";

SWIGINTERN void SWIG_WASMJS_set_error(int code, const char *msg) {
  SWIG_lasterror_code = code;
  if (msg) {
    size_t n = 0;
    while (msg[n] && n < sizeof(SWIG_lasterror_msg) - 1) ++n;
    for (size_t i = 0; i < n; ++i) SWIG_lasterror_msg[i] = msg[i];
    SWIG_lasterror_msg[n] = '\0';
  } else {
    SWIG_lasterror_msg[0] = '\0';
  }
}

/* The wrappers emit a 'fail:' label after the regular return path
   (wasm_js.cxx::cpp_call_body).  goto-driven fast exit on conversion
   failure; the JS dispatcher checks _swig_last_error_code() after each
   call and throws. */
#define SWIG_fail                                       goto fail
#define SWIG_exception_fail(code, msg)                  do { SWIG_WASMJS_set_error((code), (msg)); goto fail; } while (0)
#define SWIG_exception(code, msg)                       do { SWIG_WASMJS_set_error((code), (msg)); } while (0)
#define SWIG_Error(code, msg)                           do { SWIG_WASMJS_set_error((code), (msg)); } while (0)

#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_WASMJS_ConvertPtr(obj, (void**)(pptr), type, flags)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_WASMJS_ConvertPtrAndOwn(obj, (void**)(pptr), type, flags, own)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_WASMJS_NewPointerObj((void*)(ptr), type, flags)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NewPointerObj(ptr, type, 0)

#define SWIG_MODULE_CLIENTDATA_TYPE void*

/* JS-visible accessors.  Reading either clears the slot, so consecutive
   reads are well-defined (subsequent ones see 0 / ""). */
extern "C" EMSCRIPTEN_KEEPALIVE int swig_last_error_code(void) {
  int c = SWIG_lasterror_code;
  SWIG_lasterror_code = 0;
  return c;
}
extern "C" EMSCRIPTEN_KEEPALIVE const char* swig_last_error_msg(void) {
  return SWIG_lasterror_msg;
}

#ifndef SWIGINTERN
#define SWIGINTERN       static
#endif
#ifndef SWIGINTERNINLINE
#define SWIGINTERNINLINE static inline
#endif

/* The generator specializes this trait for registered wrapped classes. */
namespace swig_wasmjs {
using emscripten::val;
inline val borrowed_value(EM_VAL handle) {
  val borrowed = val::take_ownership(handle);
  val owned(borrowed);
  borrowed.release_ownership();
  return owned;
}

/* Enums retain their compiler-selected underlying width and signedness. */
template <class T> struct enum_conversion {
  typedef typename std::underlying_type<T>::type underlying_type;
  static bool read(const val &value, T *result) {
    const std::string kind = value.typeOf().as<std::string>();
    underlying_type converted;
    if (sizeof(underlying_type) == 8) {
      if (kind != "bigint") return false;
      val bounded = val::global("BigInt").call<val>(
          std::is_signed<underlying_type>::value ? "asIntN" : "asUintN", 64, value);
      if (!bounded.strictlyEquals(value)) return false;
      converted = value.as<underlying_type>();
    } else {
      if (kind != "number") return false;
      double number = value.as<double>();
      if (!std::isfinite(number) || std::trunc(number) != number ||
          number < static_cast<double>(std::numeric_limits<underlying_type>::lowest()) ||
          number > static_cast<double>(std::numeric_limits<underlying_type>::max())) return false;
      converted = static_cast<underlying_type>(number);
    }
    if (result) *result = static_cast<T>(converted);
    return true;
  }
  static val write(T value) {
    if (std::is_same<underlying_type, bool>::value)
      return val(static_cast<unsigned>(value));
    return val(static_cast<underlying_type>(value));
  }
};

template <class T> struct type_descriptor {
  static swig_type_info *get() { return 0; }
};
}


SWIGRUNTIME int
SWIG_WASMJS_ConvertPtrAndOwn(EM_VAL obj, void **pptr, swig_type_info *type,
                             int SWIGUNUSEDPARM(flags), int *own) {
  if (!obj) return SWIG_ERROR;
  emscripten::val v = swig_wasmjs::borrowed_value(obj);
  const std::string kind = v.typeOf().as<std::string>();
  if (v.isNull() || v.isUndefined() || (kind != "object" && kind != "function"))
    return SWIG_ERROR;
  bool has_ptr = v.hasOwnProperty("_ptr");
  if (!has_ptr) {
    return SWIG_ERROR;
  }
  uintptr_t raw = v["_ptr"].as<uintptr_t>();
  if (!raw) return SWIG_ERROR;
  void *p = reinterpret_cast<void*>(raw);
  bool type_ok = true;
  if (type) {
    type_ok = false;
    /* '_swig_type' lives on the proxy prototype, not as an own
       property -- read through proto chain and check typeof. */
    emscripten::val tprop = v["_swig_type"];
    if (tprop.typeOf().as<std::string>() == "string") {
      std::string vtag = tprop.as<std::string>();
      if (vtag == type->name) {
        /* Direct match: requested type IS the proxy's type, no
           offset adjustment needed. */
        type_ok = true;
      } else {
        /* Cast required.  Walk 'type->cast' looking for an entry whose
           'type->name' matches the proxy's tag.  When found, invoke
           the converter -- the C++ cast helper that applies inheritance
           offsets (e.g. '(Function*)(Callback*)x' for Callback->Function).

           Important: SWIG cast_info arrays are TERMINATED by a sentinel
           '{0, 0, 0, 0}' and entries are visited via POINTER ARITHMETIC
           (++cast), not the 'next' linked-list pointer.  The 'next'
           field is only populated by SWIG_InitializeModule, which we
           skip in the wasm-js runtime.  Without init, 'next == NULL'
           on every entry -- so 'cast = cast->next' would terminate
           after the first entry, missing all the casts we need. */
        swig_cast_info *cast = type->cast;
        while (cast && cast->type && cast->type->name) {
          if (vtag == cast->type->name) {
            type_ok = true;
            if (cast->converter) {
              int newmemory = 0;
              p = cast->converter(p, &newmemory);
            }
            break;
          }
          ++cast;
        }
      }
    }
  }
  if (!type_ok) return SWIG_ERROR;
  if (pptr) *pptr = p;
  if (own)  *own  = 0;
  return SWIG_OK;
}

SWIGRUNTIME int
SWIG_WASMJS_ConvertPtr(EM_VAL obj, void **pptr, swig_type_info *type, int flags) {
  return SWIG_WASMJS_ConvertPtrAndOwn(obj, pptr, type, flags, 0);
}

/* Wrap a raw C++ pointer in a fully-typed JS proxy instance.
   When 'type->clientdata' is non-null (set by SWIG_WASMJS_init_cast_chains
   to the JS class name, e.g. "MX"), call back into JS via
   'M.__wrap_<JsName>(ptr, owns)' -- which does
   'new JsName(__PRIVATE_CTOR, ptr, owns)' -- to produce a real proxy
   with '_swig_type' on the prototype.  Mirrors matlabrun.swg::
   SWIG_Matlab_NewPointerObj's mexCallMATLAB("<Class>_construct",...)
   call.  Falls back to a bare '{_ptr}' carrier when clientdata is unset
   (untyped pointers, types without a registered class).

   The 'owns' boolean (derived from SWIG_POINTER_OWN) tells the proxy
   whether JS is responsible for calling SWIG_<C>_delete on GC.  Value
   returns ("SwigValueWrapper<T>" path -- 'new T(result)' heap-clones)
   pass SWIG_POINTER_OWN; pointer/ref returns that share C++-internal
   storage pass 0.  The proxy's PRIVATE_CTOR branch FR-registers only
   when owns=1.  Without this, owning proxies leaked (every
   'f.call()', 'opti.solve()', 'vertcat(...)' etc. orphaned its heap
   wrapper).  Mirrors python.cxx's SwigPyObject.own and matlab.cxx's
   SwigPtr.own. */
SWIGRUNTIME EM_VAL
SWIG_WASMJS_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  if (!ptr) return emscripten::val::null().release_ownership();
  if (type && type->clientdata) {
    const char *js_name = (const char *)type->clientdata;
    std::string attr = "__wrap_";
    attr += js_name;
    emscripten::val wrap = emscripten::val::module_property(attr.c_str());
    if (!wrap.isUndefined() && !wrap.isNull()) {
      int owns = (flags & SWIG_POINTER_OWN) ? 1 : 0;
      emscripten::val proxy = wrap(
        emscripten::val(reinterpret_cast<uintptr_t>(ptr)),
        emscripten::val(owns));
      return proxy.release_ownership();
    }
  }
  emscripten::val obj = emscripten::val::object();
  obj.set("_ptr", emscripten::val(reinterpret_cast<uintptr_t>(ptr)));
  return obj.release_ownership();
}

/* Embind translator: bridges JS-level objects to EM_VAL handles that
   raw EMSCRIPTEN_KEEPALIVE wrappers can consume.  Without going all-in
   on embind function() registration for every wrapped C++ function,
   we expose ONE translator pair that JS calls to convert a JS value
   <-> EM_VAL handle (the i32 index into Embind's value table).

   Usage from JS:
     const h = Module.__swig_take_handle(jsObj);
     Module._swig_foo(h);          // wasm receives the EM_VAL via i32
     // exported wrappers own h using RAII; conversion helpers borrow it.
     // JS must not release or reuse h after the call.

   And the reverse for returns:
     const val = Module.__swig_release_handle(h);  // h came from wasm */
/* Embind's 'function()' binding system doesn't know about EM_VAL --
   it's the value-table handle type embind uses internally and isn't
   registered as a wire type.  Pass the handle as 'uintptr_t' instead;
   same i32 wire format, just a type embind already understands. */
SWIGINTERN uintptr_t swig_wasmjs_take_handle(emscripten::val v) {
  return reinterpret_cast<uintptr_t>(v.release_ownership());
}
SWIGINTERN emscripten::val swig_wasmjs_release_handle(uintptr_t e) {
  return emscripten::val::take_ownership(reinterpret_cast<EM_VAL>(e));
}
EMSCRIPTEN_BINDINGS(swig_wasmjs_runtime) {
  emscripten::function("__swig_take_handle",    &swig_wasmjs_take_handle);
  emscripten::function("__swig_release_handle", &swig_wasmjs_release_handle);
}

SWIGRUNTIME const char* SWIG_ErrorType(int code) {
  switch (code) {
    case SWIG_MemoryError:      return "SWIG:MemoryError";
    case SWIG_IOError:          return "SWIG:IOError";
    case SWIG_RuntimeError:     return "SWIG:RuntimeError";
    case SWIG_IndexError:       return "SWIG:IndexError";
    case SWIG_TypeError:        return "SWIG:TypeError";
    case SWIG_DivisionByZero:   return "SWIG:DivisionByZero";
    case SWIG_OverflowError:    return "SWIG:OverflowError";
    case SWIG_SyntaxError:      return "SWIG:SyntaxError";
    case SWIG_ValueError:       return "SWIG:ValueError";
    case SWIG_SystemError:      return "SWIG:SystemError";
    case SWIG_AttributeError:   return "SWIG:AttributeError";
    case SWIG_NullReferenceError: return "SWIG:NullReferenceError";
    default:                    return "SWIG:UnknownError";
  }
}

#define SWIG_DirOutFail(code, msg) \
  Swig::DirectorTypeMismatchException::raise(SWIG_ErrorType(code), msg)

/* Forward decl: definition emitted by wasm_js.cxx::top() alongside
   the swig_js_classes[] table (needs swig_type_initial[] which lives
   in the wrappers section, declared later in the generated .cpp). */
SWIGRUNTIME swig_type_info* SWIG_WASMJS_LookupByJsName(const char* js_name);

/* Wrap a raw C++ pointer via M.__wrap_<js_name>(ptr).  Bypasses
   swig_type_info, so usable for vector types (XVector) whose
   pointer-to-vector is NOT registered in swig_type_initial[] (SWIG
   only adds pointer types referenced via $descriptor in a wrapper
   signature; std::vector<M>* is rarely such -- vectors flow as values
   from from_ptr<vec<M>> via this helper).  Mirrors the body of
   SWIG_WASMJS_NewPointerObj's clientdata branch. */
/* Caller always passes a heap-allocated 'ptr' (the from_ptr<vec<M>>
   template uses 'new std::vector<M>(*a)'), so owns=1 is hard-coded. */
SWIGRUNTIME EM_VAL SWIG_WASMJS_WrapByName(void *ptr, const char *js_name) {
  if (!ptr) return 0;
  if (js_name) {
    std::string attr = "__wrap_";
    attr += js_name;
    emscripten::val wrap = emscripten::val::module_property(attr.c_str());
    if (!wrap.isUndefined() && !wrap.isNull()) {
      emscripten::val proxy = wrap(
        emscripten::val(reinterpret_cast<uintptr_t>(ptr)),
        emscripten::val(1));
      return proxy.release_ownership();
    }
  }
  emscripten::val obj = emscripten::val::object();
  obj.set("_ptr", emscripten::val(reinterpret_cast<uintptr_t>(ptr)));
  return obj.release_ownership();
}

/* Stubs for SwigModule machinery referenced by swigrun.swg when
   SWIG_MODULE_CLIENTDATA_TYPE is defined. */
static swig_module_info swig_wasmjs_module = { 0, 0, 0, 0, 0, 0 };

SWIGRUNTIME swig_module_info *
SWIG_WASMJS_GetModule(void *SWIGUNUSEDPARM(clientdata)) {
  return &swig_wasmjs_module;
}

SWIGRUNTIME void
SWIG_WASMJS_SetModule(void *SWIGUNUSEDPARM(clientdata), swig_module_info *pointer) {
  swig_wasmjs_module = *pointer;
}

#define SWIG_GetModule(clientdata)            SWIG_WASMJS_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)   SWIG_WASMJS_SetModule(clientdata, pointer)
