/* julia.swg -- typemap library for the -julia target.
 *
 * Standard names (ctype / in / out / freearg) with standard placeholders
 * drive the extern-"C" boundary; julia-prefixed names (jltype / jlparam /
 * jlout) drive the generated .jl method surface:
 *   jltype  -- ccall argument/return type (Cdouble, Ptr{Cvoid}, ...)
 *   jlparam -- user-facing ::Type annotation on the Julia method parameter
 *   jlout   -- Julia expression converting the checked ccall result;
 *              '$call' is substituted with the ccall expression
 */

%include <juliaruntime.swg>
%include <juliaprimtypes.swg>

/* Director typemap failure macros (interface .i directorin/directorout bodies
   use these; the Julia error model surfaces them as C++ exceptions caught by
   SWIG_JL_CATCH).  Defined here since the Julia backend does not pull in
   Lib/typemaps/swigtypemaps.swg. */
#define %dirout_fail(code, msg)    throw std::runtime_error(msg)
#define %dirout_nullref(msg)       throw std::runtime_error(msg)

/* ---- numeric primitives ---- */
%typemap(ctype)  double, const double&, float, const float& "double"
%typemap(in)     double, float %{ $1 = ($1_ltype)$input; %}
%typemap(in)     const double& (double tmp), const float& (float tmp) %{ tmp = ($*1_ltype)$input; $1 = &tmp; %}
%typemap(out)    double, float %{ $result = (double)$1; %}
%typemap(out)    const double&, const float& %{ $result = (double)*$1; %}
%typemap(jltype) double, const double&, float, const float& "Cdouble"
%typemap(jlparam) double, const double&, float, const float& "Real"
%typemap(jlout)  double, const double&, float, const float& "_check($call)"

%define JULIA_INTEGER(TYPE, JTYPE)
%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) TYPE, const TYPE& "$1 = 1;"
%typemap(ctype) TYPE, const TYPE& "TYPE"
%typemap(in) TYPE %{ $1 = ($1_ltype)$input; %}
%typemap(in) const TYPE& (TYPE tmp) %{ tmp = $input; $1 = &tmp; %}
%typemap(out) TYPE %{ $result = (TYPE)$1; %}
%typemap(out) const TYPE& %{ $result = (TYPE)*$1; %}
%typemap(jltype) TYPE, const TYPE& "JTYPE"
%typemap(jlparam) TYPE, const TYPE& "Integer"
%typemap(jlout) TYPE, const TYPE& "_check($call)"
%enddef

JULIA_INTEGER(char, Cchar)
JULIA_INTEGER(signed char, Int8)
JULIA_INTEGER(unsigned char, Cuchar)
JULIA_INTEGER(short, Cshort)
JULIA_INTEGER(unsigned short, Cushort)
JULIA_INTEGER(int, Cint)
JULIA_INTEGER(unsigned int, Cuint)
JULIA_INTEGER(long, Clong)
JULIA_INTEGER(unsigned long, Culong)
JULIA_INTEGER(long long, Clonglong)
JULIA_INTEGER(unsigned long long, Culonglong)
JULIA_INTEGER(size_t, Csize_t)

%typemap(ctype)  bool, const bool& "unsigned char"
%typemap(in)     bool %{ $1 = $input != 0; %}
%typemap(in) const bool& (bool tmp) %{ tmp = $input != 0; $1 = &tmp; %}
%typemap(out)    bool %{ $result = $1 ? 1 : 0; %}
%typemap(out)    const bool& %{ $result = *$1 ? 1 : 0; %}
%typemap(jltype) bool, const bool& "Cuchar"
%typemap(jlparam) bool, const bool& "Bool"
%typemap(jlout)  bool, const bool& "_check($call) != 0"

%typemap(ctype)  void "void"
%typemap(out)    void "";
%typemap(jltype) void "Cvoid"
%typemap(jlout)  void "($call; _check(nothing))"

/* ---- strings ---- */
%typemap(ctype) std::string, const std::string& "jl_value_t *"
%typemap(in) std::string %{
  if (!jl_is_string($input)) throw std::runtime_error("expected String");
  $1 = std::string(jl_string_ptr($input), jl_string_len($input));
%}
%typemap(in) const std::string& (std::string tmp) %{
  if (!jl_is_string($input)) throw std::runtime_error("expected String");
  tmp = std::string(jl_string_ptr($input), jl_string_len($input));
  $1 = &tmp;
%}
%typemap(out) std::string, const std::string& %{ $result = jl_pchar_to_string(($1).data(), ($1).size()); %}
%typemap(jltype) std::string, const std::string& "Any"
%typemap(jlparam) std::string, const std::string& "String"
%typemap(jlout) std::string, const std::string& "_check($call)::String"

%typemap(ctype)  char *, const char * "const char *"
%typemap(ctype, out="char *") char *, const char * "const char *"
%typemap(in)     char *, const char * %{ $1 = ($1_ltype)$input; %}
%typemap(out)    char *, const char * %{ $result = swig_jl_strdup($1 ? std::string($1) : std::string()); %}
%typemap(jltype) char *, const char * "Cstring"
%typemap(jltype, out="Ptr{UInt8}") char *, const char * "Cstring"
%typemap(jlparam) char *, const char * "AbstractString"
%typemap(jlout)  char *, const char * "_takestr($call)"

/* ---- director (Julia subclass -> C++ virtual) primitive marshaling.
 * directorin  ASSIGNS a jl_value_t* to $input (C++ value -> Julia value);
 * directorout READS $input (a jl_value_t* the Julia override returned) and
 * assigns $result.  Class/container bridges are supplied per-type by the
 * interface .i (the matcher does not generalise instantiated templates). */
%typemap(directorin)  bool        %{ $input = jl_box_bool($1 ? 1 : 0); %}
%typemap(directorin)  int, long, long long, short
                                   %{ $input = jl_box_int64((int64_t)$1); %}
%typemap(directorin)  size_t, unsigned int, unsigned long, unsigned short %{
  if ((uint64_t)$1 > (uint64_t)std::numeric_limits<int64_t>::max())
    throw std::runtime_error("integer director argument is out of range");
  $input = jl_box_int64((int64_t)$1);
%}
%typemap(directorin)  double, float %{ $input = jl_box_float64((double)$1); %}
%typemap(directorin)  std::string, const std::string& %{ $input = jl_pchar_to_string(($1).data(), ($1).size()); %}
%typemap(directorin)  char *, const char * %{ $input = jl_cstr_to_string($1 ? $1 : ""); %}

%typemap(directorout) bool %{ if (!jl_typeis($input, jl_bool_type)) { throw std::runtime_error("expected Bool director result"); } $result = jl_unbox_bool($input) != 0; %}
%typemap(directorout) int, long, long long, short, size_t, unsigned int, unsigned long, unsigned short
                                   %{
  if (!jl_typeis($input, jl_int64_type)) throw std::runtime_error("expected Int64 director result");
  if (!SWIG_IsOK(swig_jl_asval($input, &$result)))
    throw std::runtime_error("integer director result is out of range");
%}
%typemap(directorout) double, float %{ if (!jl_typeis($input, jl_float64_type)) { throw std::runtime_error("expected Float64 director result"); } $result = ($1_ltype)jl_unbox_float64($input); %}
%typemap(directorout) std::string %{ if (!jl_is_string($input)) { throw std::runtime_error("expected String director result"); } $result = std::string(jl_string_ptr($input), jl_string_len($input)); %}

/* ---- enums: checked conversion through the compiler's underlying type ---- */
%typemap(ctype)  enum SWIGTYPE, const enum SWIGTYPE& "jl_value_t *"
%typemap(in)     enum SWIGTYPE %{ $1 = swig_jl_enum_read<$1_ltype>($input); %}
%typemap(in)     const enum SWIGTYPE& (typename std::remove_cv<$*1_ltype>::type tmp) %{ tmp = swig_jl_enum_read<$*1_ltype>($input); $1 = &tmp; %}
%typemap(out)    enum SWIGTYPE %{ $result = swig_jl_enum_box($1); %}
%typemap(out)    const enum SWIGTYPE& %{ $result = swig_jl_enum_box(*$1); %}
%typemap(jltype) enum SWIGTYPE, const enum SWIGTYPE& "Any"
%typemap(jlparam) enum SWIGTYPE, const enum SWIGTYPE& "Union{Integer,Base.Enums.Enum}"
%typemap(jlout)  enum SWIGTYPE, const enum SWIGTYPE& "_check($call)"

/* ---- generic class types: opaque pointer convention ---- */
%typemap(ctype, out="void *") SWIGTYPE, SWIGTYPE&, const SWIGTYPE&, SWIGTYPE* "jl_value_t *"
%typemap(in) SWIGTYPE (void *ptr = 0) %{
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $&descriptor, 0)) || !ptr)
    throw std::runtime_error("expected a live wrapped object");
  $1 = *($&1_ltype)ptr;
%}
%typemap(in) SWIGTYPE& (void *ptr = 0) %{
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $descriptor, 0)) || !ptr)
    throw std::runtime_error("expected a live wrapped object");
  $1 = ($1_ltype)ptr;
%}
%typemap(in) const SWIGTYPE& (void *ptr = 0) %{
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $descriptor, 0)) || !ptr)
    throw std::runtime_error("expected a live wrapped object");
  $1 = ($1_ltype)ptr;
%}
%typemap(in) SWIGTYPE* (void *ptr = 0) %{
  if (!SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $descriptor, 0)))
    throw std::runtime_error("expected a live wrapped object");
  $1 = ($1_ltype)ptr;
%}
%typemap(out)    SWIGTYPE %{ $result = (void*) new $1_ltype($1); %}
%typemap(out)    SWIGTYPE& %{ $result = (void*)$1; %}
%typemap(out)    const SWIGTYPE& %{ $result = (void*)$1; %}
%typemap(out)    SWIGTYPE* %{ $result = (void*)$1; %}
%typemap(jltype, out="Ptr{Cvoid}") SWIGTYPE, SWIGTYPE&, const SWIGTYPE&, SWIGTYPE* "Any"
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) SWIGTYPE*, SWIGTYPE&, const SWIGTYPE& %{
  void *ptr = 0;
  $1 = SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $descriptor, 0)) && ptr;
%}
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) SWIGTYPE %{
  void *ptr = 0;
  $1 = SWIG_IsOK(SWIG_ConvertPtr($input, &ptr, $&descriptor, 0)) && ptr;
%}
/* jlparam / jlout for class types are computed by the backend (proxy name). */

/* ---- jl_value_t* route: composite values cross as native Julia values.
 * The wrapper uses the Julia C API. ccall arguments are rooted by the
 * caller; C-side intermediates use JL_GC_PUSH*. */
%fragment("SwigJlRuntime", "header") %{
#include <julia.h>
#include <vector>
#include <string>
#include <stdexcept>
/* Access arrays through Julia methods. Build against the headers of the running Julia version. */
static inline size_t swig_jl_array_len(jl_value_t* v) {
  jl_value_t* L = jl_call1(jl_get_function(jl_base_module, "length"), v);
  if (!L) throw std::runtime_error("length() failed");
  return (size_t)jl_unbox_int64(L);
}
template <typename T> static T* swig_jl_array_ptr(jl_value_t* v) {
  /* pointer(a) returns a Ptr{eltype}; boxed as a Julia pointer value. */
  jl_value_t* P = jl_call1(jl_get_function(jl_base_module, "pointer"), v);
  if (!P) throw std::runtime_error("pointer() failed");
  return (T*)jl_unbox_voidpointer(P);
}
/* Boxed (Any/String/...) element get/set via getindex/setindex! (1-based).
   jl_array_ptr_ref/_set are STATIC_INLINE layout-deref in julia 1.11+, so the
   ABI-stable route is to call through libjulia.  Callers GC-root the array. */
static inline jl_value_t* swig_jl_aref(jl_value_t* a, size_t i) {
  jl_value_t* idx = jl_box_int64((int64_t)(i + 1));
  JL_GC_PUSH1(&idx);
  jl_value_t* args[2] = { a, idx };
  jl_value_t* r = jl_call(jl_get_function(jl_base_module, "getindex"), args, 2);
  JL_GC_POP();
  if (!r) throw std::runtime_error("getindex failed");
  return r;
}
static inline void swig_jl_aset(jl_value_t* a, size_t i, jl_value_t* x) {
  jl_value_t* idx = 0;
  JL_GC_PUSH2(&idx, &x);
  idx = jl_box_int64((int64_t)(i + 1));
  jl_value_t* args[3] = { a, x, idx };  /* setindex!(a, v, i) */
  jl_value_t* r = jl_call(jl_get_function(jl_base_module, "setindex!"), args, 3);
  JL_GC_POP();
  if (!r) throw std::runtime_error("setindex! failed");
}
static inline std::vector<double> swig_jl_to_vec_double(jl_value_t* v) {
  if (!jl_is_array(v)) throw std::runtime_error("expected a numeric vector");
  JL_GC_PUSH1(&v);
  size_t n = swig_jl_array_len(v);
  std::vector<double> out(n);
  jl_value_t* eltype = (jl_value_t*)jl_array_eltype(v);
  if (eltype == (jl_value_t*)jl_float64_type) {
    double* data = swig_jl_array_ptr<double>(v);
    for (size_t i = 0; i < n; ++i) out[i] = data[i];
  } else if (eltype == (jl_value_t*)jl_int64_type) {
    int64_t* data = swig_jl_array_ptr<int64_t>(v);
    for (size_t i = 0; i < n; ++i) out[i] = (double)data[i];
  } else {
    JL_GC_POP();
    throw std::runtime_error("expected a Float64/Int64 vector");
  }
  JL_GC_POP();
  return out;
}
static inline std::vector<long long> swig_jl_to_vec_int(jl_value_t* v) {
  if (!jl_is_array(v)) throw std::runtime_error("expected an integer vector");
  if ((jl_value_t*)jl_array_eltype(v) != (jl_value_t*)jl_int64_type)
    throw std::runtime_error("expected an Int64 vector");
  JL_GC_PUSH1(&v);
  size_t n = swig_jl_array_len(v);
  std::vector<long long> out(n);
  int64_t* data = swig_jl_array_ptr<int64_t>(v);
  for (size_t i = 0; i < n; ++i) out[i] = (long long)data[i];
  JL_GC_POP();
  return out;
}
static inline std::vector<std::string> swig_jl_to_vec_string(jl_value_t* v) {
  if (!jl_is_array(v)) throw std::runtime_error("expected a string vector");
  JL_GC_PUSH1(&v);
  size_t n = swig_jl_array_len(v);
  std::vector<std::string> out(n);
  for (size_t i = 0; i < n; ++i) {
    jl_value_t* el = swig_jl_aref(v, i);
    if (!jl_is_string(el)) { JL_GC_POP(); throw std::runtime_error("expected a string vector"); }
    out[i] = std::string(jl_string_ptr(el), jl_string_len(el));
  }
  JL_GC_POP();
  return out;
}
static inline jl_value_t* swig_jl_from_vec_double(const std::vector<double>& v) {
  jl_value_t* atype = jl_apply_array_type((jl_value_t*)jl_float64_type, 1);
  jl_array_t* a = 0;
  JL_GC_PUSH2(&atype, &a);
  a = jl_alloc_array_1d(atype, v.size());
  double* data = swig_jl_array_ptr<double>((jl_value_t*)a);
  for (size_t i = 0; i < v.size(); ++i) data[i] = v[i];
  JL_GC_POP();
  return (jl_value_t*)a;
}
static inline jl_value_t* swig_jl_from_vec_int(const std::vector<long long>& v) {
  jl_value_t* atype = jl_apply_array_type((jl_value_t*)jl_int64_type, 1);
  jl_array_t* a = 0;
  JL_GC_PUSH2(&atype, &a);
  a = jl_alloc_array_1d(atype, v.size());
  int64_t* data = swig_jl_array_ptr<int64_t>((jl_value_t*)a);
  for (size_t i = 0; i < v.size(); ++i) data[i] = (int64_t)v[i];
  JL_GC_POP();
  return (jl_value_t*)a;
}
static inline jl_value_t* swig_jl_from_vec_string(const std::vector<std::string>& v) {
  jl_value_t* atype = jl_apply_array_type((jl_value_t*)jl_string_type, 1);
  jl_array_t* a = 0;
  JL_GC_PUSH2(&atype, &a);
  a = jl_alloc_array_1d(atype, v.size());
  for (size_t i = 0; i < v.size(); ++i)
    swig_jl_aset((jl_value_t*)a, i, jl_pchar_to_string(v[i].data(), v[i].size()));
  JL_GC_POP();
  return (jl_value_t*)a;
}
/* pair -> Julia 2-tuple (each element pre-boxed by the backend-synthesised
   marshaling for std::pair returns; see julia.cxx synth_template_return). */
static inline jl_value_t* swig_jl_make_tuple2(jl_value_t* a, jl_value_t* b) {
  JL_GC_PUSH2(&a, &b);
  jl_value_t* vals[2] = { a, b };
  jl_value_t* r = jl_call(jl_get_function(jl_core_module, "tuple"), vals, 2);
  JL_GC_POP();
  return r;
}
%}

%typemap(ctype, fragment="SwigJlRuntime")  std::vector<double>, const std::vector<double>& "jl_value_t*"
%typemap(in)     std::vector<double> %{ $1 = swig_jl_to_vec_double($input); %}
%typemap(in)     const std::vector<double>& (std::vector<double> tmp) %{ tmp = swig_jl_to_vec_double($input); $1 = &tmp; %}
%typemap(out)    std::vector<double>, const std::vector<double>& %{ $result = swig_jl_from_vec_double($1); %}
%typemap(jltype) std::vector<double>, const std::vector<double>& "Any"
%typemap(jlparam) std::vector<double>, const std::vector<double>& "Union{Vector{Float64},Vector{Int64}}"
%typemap(jlout)  std::vector<double>, const std::vector<double>& "_check($call)::Vector{Float64}"

%typemap(ctype, fragment="SwigJlRuntime")  std::vector<long long>, const std::vector<long long>& "jl_value_t*"
%typemap(in)     std::vector<long long> %{ $1 = swig_jl_to_vec_int($input); %}
%typemap(in)     const std::vector<long long>& (std::vector<long long> tmp) %{ tmp = swig_jl_to_vec_int($input); $1 = &tmp; %}
%typemap(out)    std::vector<long long>, const std::vector<long long>& %{ $result = swig_jl_from_vec_int($1); %}
%typemap(jltype) std::vector<long long>, const std::vector<long long>& "Any"
%typemap(jlparam) std::vector<long long>, const std::vector<long long>& "Vector{Int64}"
%typemap(jlout)  std::vector<long long>, const std::vector<long long>& "_check($call)::Vector{Int64}"

%typemap(ctype, fragment="SwigJlRuntime")  std::vector<std::string>, const std::vector<std::string>& "jl_value_t*"
%typemap(in)     std::vector<std::string> %{ $1 = swig_jl_to_vec_string($input); %}
%typemap(in)     const std::vector<std::string>& (std::vector<std::string> tmp) %{ tmp = swig_jl_to_vec_string($input); $1 = &tmp; %}
%typemap(out)    std::vector<std::string>, const std::vector<std::string>& %{ $result = swig_jl_from_vec_string($1); %}
%typemap(jltype) std::vector<std::string>, const std::vector<std::string>& "Any"
%typemap(jlparam) std::vector<std::string>, const std::vector<std::string>& "Vector{String}"
%typemap(jlout)  std::vector<std::string>, const std::vector<std::string>& "_check($call)::Vector{String}"

/* std::vector<class> and std::pair returns are marshalled by backend-
   synthesised code (julia.cxx synth_template_return), since the typemap
   matcher does not generalise instantiated template args to SWIGTYPE.  The
   synthesised C uses jl_apply_array_type / SWIG_NewPointerObj / the
   swig_jl_make_tuple2 helper above (all reachable via SwigJlRuntime). */

/* ---- runtime support for interface libraries ----
 * Pointer carriers: a Julia proxy (mutable struct with a 'ptr::Ptr{Cvoid}'
 * field) crosses as jl_value_t*; SWIG_ConvertPtr reads the field.  Type
 * validation is deferred to Julia-side dispatch on the proxy types. */

%typemap(typecheck, precedence=SWIG_TYPECHECK_DOUBLE) double, const double&, float, const float& "$1 = 1;"
%typemap(typecheck, precedence=SWIG_TYPECHECK_BOOL) bool, const bool& "$1 = 1;"
%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING) char *, const char *, std::string, const std::string& "$1 = 1;"
%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) enum SWIGTYPE %{
  try { swig_jl_enum_read<$1_ltype>($input); $1 = 1; } catch (...) { $1 = 0; }
%}
%typemap(typecheck, precedence=SWIG_TYPECHECK_INTEGER) const enum SWIGTYPE& %{
  try { swig_jl_enum_read<$*1_ltype>($input); $1 = 1; } catch (...) { $1 = 0; }
%}

%typemap(throws) SWIGTYPE %{ (void)$1; throw; %}

%define JULIA_POINTER(TYPE)
%typemap(ctype) TYPE *, const TYPE * "void *"
%typemap(in) TYPE *, const TYPE * %{ $1 = ($1_ltype)$input; %}
%typemap(out) TYPE *, const TYPE * %{ $result = (void *)$1; %}
%typemap(jltype) TYPE *, const TYPE * "Ptr{Cvoid}"
%typemap(jlparam) TYPE *, const TYPE * "Ptr"
%typemap(jlout) TYPE *, const TYPE * "_check($call)"
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER) TYPE *, const TYPE * "$1 = 1;"
%enddef

JULIA_POINTER(void)
JULIA_POINTER(bool)
JULIA_POINTER(short)
JULIA_POINTER(unsigned short)
JULIA_POINTER(int)
JULIA_POINTER(unsigned int)
JULIA_POINTER(long)
JULIA_POINTER(unsigned long)
JULIA_POINTER(long long)
JULIA_POINTER(unsigned long long)
JULIA_POINTER(float)
JULIA_POINTER(double)
