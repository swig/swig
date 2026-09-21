/* juliaruntime.swg -- SWIG runtime for the -julia target.
   swigrun.swg supplies swig_type_info & the type system; ConvertPtr reads
   the first (ptr) field of a Julia mutable-struct proxy.  Type validation
   is deferred to Julia-side dispatch on the proxy types. */
%insert(runtime) %{
#include <cstdlib>
#include <cstring>
#include <julia.h>
%}
%insert(runtime) "swigrun.swg";
%insert(runtime) "swiglabels.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) %{
/* Julia-proxy-name -> swig_type_info registry, filled by the generated
   _swig_jl_init_types() (called from the module __init__).  ConvertPtr
   validates the proxy's Julia type against the expected descriptor via
   the SWIG cast chains (derived -> base accepted, with pointer
   adjustment); unknown names with a non-null expected type are rejected. */
#include <map>
#include <string>
SWIGRUNTIME std::map<std::string, swig_type_info*>& swig_jl_proxy_registry() {
  static std::map<std::string, swig_type_info*> reg;
  return reg;
}
SWIGRUNTIME std::map<std::string, jl_value_t*>& swig_jl_proxy_types() {
  static std::map<std::string, jl_value_t*> reg;  /* Julia DataTypes: globally rooted */
  return reg;
}
SWIGRUNTIME std::map<swig_type_info*, jl_value_t*>& swig_jl_ti2type() {
  static std::map<swig_type_info*, jl_value_t*> reg;
  return reg;
}
extern "C" SWIGEXPORT void swig_jl_register_proxy_type(const char* jlname, jl_value_t* jltype) {
  swig_jl_proxy_types()[jlname] = jltype;
  std::map<std::string, swig_type_info*>::iterator it = swig_jl_proxy_registry().find(jlname);
  if (it != swig_jl_proxy_registry().end()) swig_jl_ti2type()[it->second] = jltype;
}
SWIGRUNTIME void swig_jl_register_proxy(const char* jlname, swig_type_info* ti) {
  if (ti) swig_jl_proxy_registry()[jlname] = ti;
}
SWIGRUNTIME int swig_jl_convert_ptr(jl_value_t* p, void** out, swig_type_info* type) {
  if (!p) return SWIG_ERROR;
  if (jl_is_nothing(p)) { if (out) *out = 0; return SWIG_OK; }
  jl_value_t* t = jl_typeof(p);
  if (!jl_is_mutable_datatype(t)) return SWIG_ERROR;
  jl_datatype_t* dt = (jl_datatype_t*)t;
  if (jl_datatype_nfields(dt) < 1) return SWIG_ERROR;
  jl_value_t* f = jl_get_nth_field(p, 0);
  if (!f || !jl_typeis(f, jl_voidpointer_type)) return SWIG_ERROR;
  void* raw = jl_unbox_voidpointer(f);
  if (!raw) return SWIG_ERROR;
  if (type) {
    const char *jlname = 0;
    for (std::map<std::string, jl_value_t*>::iterator it = swig_jl_proxy_types().begin(); it != swig_jl_proxy_types().end(); ++it) {
      if (it->second == t) { jlname = it->first.c_str(); break; }
    }
    if (!jlname) return SWIG_ERROR;
    std::map<std::string, swig_type_info*>& reg = swig_jl_proxy_registry();
    std::map<std::string, swig_type_info*>::iterator it = reg.find(jlname);
    if (it == reg.end()) return SWIG_ERROR;
    if (it->second != type) {
      swig_cast_info* cast = SWIG_TypeCheckStruct(it->second, type);
      if (!cast) return SWIG_ERROR;
      int newmemory = 0;
      raw = SWIG_TypeCast(cast, raw, &newmemory);
    }
  }
  if (out) *out = raw;
  return SWIG_OK;
}
#define SWIG_ConvertPtr(obj, pptr, type, flags) swig_jl_convert_ptr(obj, pptr, type)
/* Returns are wrapped Julia-side (proxy ctor over void*); from_ptr paths
   that build GUESTOBJECT returns box the pointer for the .jl layer. */
SWIGRUNTIME jl_value_t* swig_jl_new_pointer_obj(void* ptr, swig_type_info* type, int flags) {
  if (type) {
    std::map<swig_type_info*, jl_value_t*>::iterator it = swig_jl_ti2type().find(type);
    if (it == swig_jl_ti2type().end()) {
      /* fallback: match by mangled name (duplicate table entries) */
      for (std::map<std::string, swig_type_info*>::iterator r = swig_jl_proxy_registry().begin();
           r != swig_jl_proxy_registry().end(); ++r) {
        if (r->second && type->name && strcmp(r->second->name, type->name) == 0) {
          std::map<std::string, jl_value_t*>::iterator t2 = swig_jl_proxy_types().find(r->first);
          if (t2 != swig_jl_proxy_types().end()) {
            swig_jl_ti2type()[type] = t2->second;
            it = swig_jl_ti2type().find(type);
          }
          break;
        }
      }
    }
    if (it != swig_jl_ti2type().end()) {
      jl_value_t* boxed = jl_box_voidpointer(ptr);
      JL_GC_PUSH1(&boxed);
      jl_value_t* r = jl_call2((jl_value_t*)it->second, boxed, jl_box_bool((flags & SWIG_POINTER_OWN) != 0));
      JL_GC_POP();
      if (!r) throw std::runtime_error("unable to construct Julia proxy");
      return r;
    }
  }
  return jl_box_voidpointer(ptr);
}
#define SWIG_NewPointerObj(ptr, type, flags) swig_jl_new_pointer_obj(ptr, type, flags)
#define SWIG_exception_fail(code, msg) do { throw std::runtime_error(msg); } while (0)
#define SWIG_exception(code, msg)      do { throw std::runtime_error(msg); } while (0)
#define SWIG_fail                      throw std::runtime_error("SWIG conversion failed")
%}
%insert(runtime) %{
/* %append_output target: first output returned bare; further outputs grow a tuple. */
SWIGRUNTIME jl_value_t* SWIG_AppendOutput(jl_value_t* cur, jl_value_t* x) {
  if (!cur) return x;
  JL_GC_PUSH2(&cur, &x);
  jl_value_t* tuple_f = jl_get_function(jl_core_module, "tuple");
  jl_value_t* r;
  if (jl_is_tuple(cur)) {
    size_t n = jl_nfields(cur);
    jl_value_t** vals = (jl_value_t**)alloca(sizeof(jl_value_t*) * (n + 1));
    for (size_t i = 0; i < n; ++i) vals[i] = jl_fieldref(cur, i);
    vals[n] = x;
    r = jl_call(tuple_f, vals, (int)(n + 1));
  } else {
    jl_value_t* vals[2] = { cur, x };
    r = jl_call(tuple_f, vals, 2);
  }
  JL_GC_POP();
  return r;
}
%}
%insert(runtime) %{
/* single-module process: no cross-module type sharing */
#define SWIG_GetModule(cd) ((void)(cd), (swig_module_info *)0)
#define SWIG_SetModule(cd, m) (void)(m)
%}
%insert(init) "swiginit.swg";
