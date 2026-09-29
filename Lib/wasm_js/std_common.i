%include <wasm_jscontainers.swg>

/* Values and const references are snapshots; mutable references require proxies. */
%define %wasm_container(TYPE...)
%typemap(ctype) TYPE, const TYPE &, TYPE &, TYPE * "EM_VAL"
%typemap(in) TYPE {
  try { $1 = swig_wasmjs::conversion< $1_ltype >::read(swig_wasmjs::borrowed_value($input)); }
  catch (const swig_wasmjs::conversion_error &error) { SWIG_exception_fail(SWIG_TypeError, error.what()); }
}
%typemap(in) const TYPE & ($*1_ltype temporary) {
  try { temporary = swig_wasmjs::conversion< $*1_ltype >::read(swig_wasmjs::borrowed_value($input)); }
  catch (const swig_wasmjs::conversion_error &error) { SWIG_exception_fail(SWIG_TypeError, error.what()); }
  $1 = &temporary;
}
%typemap(in) TYPE &, TYPE * {
  void *pointer = 0;
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0)) || !pointer)
    SWIG_exception_fail(SWIG_TypeError, "Expected a compatible mutable container proxy");
  $1 = ($1_ltype)pointer;
}
%typemap(out) TYPE {
  try { $result = swig_wasmjs::to_value< $1_ltype >($1).release_ownership(); }
  catch (const swig_wasmjs::conversion_error &error) { SWIG_exception_fail(SWIG_TypeError, error.what()); }
}
%typemap(out) const TYPE & {
  try { $result = swig_wasmjs::to_value< $*1_ltype >(*$1).release_ownership(); }
  catch (const swig_wasmjs::conversion_error &error) { SWIG_exception_fail(SWIG_TypeError, error.what()); }
}
%typemap(out) TYPE & {
  $result = SWIG_NewPointerObj((void *)$1, $descriptor, $owner);
}
%typemap(out, tsstub_nullable="1") TYPE * {
  $result = SWIG_NewPointerObj((void *)$1, $descriptor, $owner);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) TYPE, const TYPE & {
  $1 = swig_wasmjs::check< TYPE >($input);
}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) TYPE &, TYPE * {
  void *pointer = 0;
  $1 = SWIG_IsOK(SWIG_ConvertPtr($input, &pointer, $descriptor, 0)) && pointer;
}
%typemap(jsarg) TYPE, const TYPE &, TYPE &, TYPE * "__unwrap($input)"
%typemap(jsout) TYPE, const TYPE &, TYPE &, TYPE * "__from_handle($call)"
%enddef

namespace std {
  template <class T> class allocator;
  template <class T> struct less;
  template <class T> struct hash;
  template <class T> struct equal_to;
}
