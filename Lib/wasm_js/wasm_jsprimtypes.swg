

/* SWIG_AsVal_frag / SWIG_From_frag macros (SWIG-level, used in %fragment names). */
/* fragments.swg depends on swigmacros.swg for %string_name / %symbol_name. */
%include <typemaps/swigmacros.swg>
%include <typemaps/fragments.swg>

/* SWIG runtime macros (status codes, ownership flag).  SWIG_ConvertPtr */
/* and SWIG_NewPointerObj live in wasm_jsrun.swg (with the proper */
/* EM_VAL signatures) -- do NOT redefine them here. */
%{
#ifndef SWIG_OK
#define SWIG_OK         (0)
#define SWIG_ERROR      (-1)
#define SWIG_TypeError  (-5)
#define SWIG_IsOK(r)    ((r) >= 0)
#endif

#ifndef SWIG_POINTER_OWN
#define SWIG_POINTER_OWN  0x1
#endif

#include <emscripten/val.h>
#include <type_traits>
#include <cmath>
#include <limits>
%}

%define %wasm_js_primtype_asval(T)
%fragment(SWIG_AsVal_frag(T), "header") {
SWIGINTERN int SWIG_AsVal_dec(T)(void* p, T* val) {
  if (!p) return SWIG_ERROR;
  emscripten::val v = swig_wasmjs::borrowed_value(reinterpret_cast< ::emscripten::EM_VAL >(p));
  std::string ty = v.typeOf().as<std::string>();
  bool ok = (ty == "number" || ty == "bigint");
  if (ok && ty == "bigint" && std::is_integral<T>::value) {
    emscripten::val bounded = emscripten::val::global("BigInt").call<emscripten::val>(
        std::is_signed<T>::value ? "asIntN" : "asUintN", static_cast<unsigned>(sizeof(T) * 8), v);
    ok = bounded.strictlyEquals(v);
    if (ok && val) {
      if (sizeof(T) == 8) *val = v.as<T>();
      else *val = static_cast<T>(emscripten::val::global("Number")(v).as<double>());
    }
  } else if (ok) {
    double d = ty == "bigint" ? emscripten::val::global("Number")(v).as<double>() : v.as<double>();
    if (std::is_integral<T>::value) {
      double bound = std::ldexp(1.0, std::numeric_limits<T>::digits);
      ok = std::isfinite(d) && std::trunc(d) == d && d >= (std::is_signed<T>::value ? -bound : 0.0) && d < bound;
    } else if (std::isfinite(d)) {
      ok = d >= -static_cast<double>(std::numeric_limits<T>::max()) && d <= static_cast<double>(std::numeric_limits<T>::max());
    } else if (ty == "bigint") {
      ok = false;
    }
    if (ok && val) *val = static_cast<T>(d);
  }
  return ok ? SWIG_OK : SWIG_ERROR;
}
}
%enddef

%define %wasm_js_primtype_from(T)
%fragment(SWIG_From_frag(T), "header") {
SWIGINTERNINLINE void* SWIG_From_dec(T)(T value) {
  return reinterpret_cast<void *>(emscripten::val(value).release_ownership());
}
}
%enddef

%define %wasm_js_primtype(T)
%wasm_js_primtype_asval(T)
%wasm_js_primtype_from(T)
%enddef

/* Boolean fragments accept only JavaScript booleans. */
%fragment(SWIG_AsVal_frag(bool), "header") {
SWIGINTERN int SWIG_AsVal_dec(bool)(void* p, bool* val) {
  if (!p) return SWIG_ERROR;
  emscripten::val v = swig_wasmjs::borrowed_value(reinterpret_cast< ::emscripten::EM_VAL >(p));
  std::string ty = v.typeOf().as<std::string>();
  /* Boolean and numeric overloads remain distinct. */
  bool ok = (ty == "boolean");
  if (ok && val) *val = v.as<bool>();
  return ok ? SWIG_OK : SWIG_ERROR;
}
}
%fragment(SWIG_From_frag(bool), "header") {
SWIGINTERNINLINE void* SWIG_From_dec(bool)(bool value) {
  return reinterpret_cast<void *>(emscripten::val(value).release_ownership());
}
}

%wasm_js_primtype(char)
%wasm_js_primtype(signed char)
%wasm_js_primtype(unsigned char)
%wasm_js_primtype(short)
%wasm_js_primtype(unsigned short)
%wasm_js_primtype(int)
%wasm_js_primtype(long)
%wasm_js_primtype(long long)
%wasm_js_primtype(double)
%wasm_js_primtype(float)
%wasm_js_primtype(unsigned int)
%wasm_js_primtype(unsigned long)
%wasm_js_primtype(unsigned long long)
