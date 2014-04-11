SWIGRUNTIME bool SWIG_check_num_args(const char *func_name, int num_args, int max_args, int min_args, int varargs) {
  if (num_args > max_args && !varargs)
    error("function %s takes at most %i arguments", func_name, max_args);
  else if (num_args < min_args)
    error("function %s requires at least %i arguments", func_name, min_args);
  else
    return true;
  return false;
}

SWIGRUNTIME octave_value SWIG_ErrorType(int code) {
  switch (code) {
  case SWIG_MemoryError:
    return "SWIG_MemoryError";
  case SWIG_IOError:
    return "SWIG_IOError";
  case SWIG_RuntimeError:
    return "SWIG_RuntimeError";
  case SWIG_IndexError:
    return "SWIG_IndexError";
  case SWIG_TypeError:
    return "SWIG_TypeError";
  case SWIG_DivisionByZero:
    return "SWIG_DivisionByZero";
  case SWIG_OverflowError:
    return "SWIG_OverflowError";
  case SWIG_SyntaxError:
    return "SWIG_SyntaxError";
  case SWIG_ValueError:
    return "SWIG_ValueError";
  case SWIG_SystemError:
    return "SWIG_SystemError";
  case SWIG_AttributeError:
    return "SWIG_AttributeError";
  }
  return "SWIG unknown error";
}

SWIGRUNTIME octave_value SWIG_Error(int code, const char *msg) {
  octave_value type(SWIG_ErrorType(code));
  std::string r = msg;
  r += " (" + type.string_value() + ")";
  error(r.c_str());
  return octave_value(r);
}

#define SWIG_fail                                       goto fail

#define SWIG_Matlab_ConvertPtr(obj, pptr, type, flags)  SWIG_Matlab_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Matlab_ConvertPtr(obj, pptr, type, flags)
#define SWIG_ConvertPtrAndOwn(obj,pptr,type,flags,own)  SWIG_Matlab_ConvertPtrAndOwn(obj, pptr, type, flags, own)
#define SWIG_ConvertPtr(obj, pptr, type, flags)         SWIG_Matlab_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewPointerObj(ptr, type, flags)            SWIG_Matlab_NewPointerObj(ptr, type, flags)
#define swig_owntype                                    int

#define SWIG_ConvertPacked(obj, ptr, sz, ty)            SWIG_Matlab_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewPackedObj(ptr, sz, type)                SWIG_Matlab_NewPackedObj(ptr, sz, type)

#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NewPointerObj(ptr, type, 0)

#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_Matlab_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_Matlab_NewPackedObj(ptr, sz, type)

#define SWIG_GetModule(clientdata) SWIG_Matlab_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer) SWIG_Matlab_SetModule(clientdata,pointer);
#define SWIG_MODULE_CLIENTDATA_TYPE void*

#define Matlab_Error_Occurred() 0
#define SWIG_Matlab_AddErrorMsg(msg) {;}

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *clientdata);
SWIGRUNTIME void SWIG_Matlab_SetModule(void *clientdata, swig_module_info *pointer);

// For backward compatibility only
#define SWIG_POINTER_EXCEPTION  0
#define SWIG_arg_fail(arg)      0

// Runtime API implementation

#include <map>
#include <vector>
#include <string>

typedef octave_value_list(*octave_func) (const octave_value_list &, int);
class octave_swig_type;

namespace Swig {

#ifdef SWIG_DIRECTORS

  class Director;

  typedef std::map < void *, Director * > rtdir_map;
  SWIGINTERN rtdir_map* get_rtdir_map();
  SWIGINTERNINLINE void set_rtdir(void *vptr, Director *d);
  SWIGINTERNINLINE void erase_rtdir(void *vptr);
  SWIGINTERNINLINE Director *get_rtdir(void *vptr);

  SWIGRUNTIME void swig_director_destroyed(octave_swig_type *self, Director *d);
  SWIGRUNTIME octave_swig_type *swig_director_get_self(Director *d);
  SWIGRUNTIME void swig_director_set_self(Director *d, octave_swig_type *self);

#endif

  SWIGRUNTIME octave_base_value *swig_value_ref(octave_swig_type *ost);
  SWIGRUNTIME octave_swig_type *swig_value_deref(octave_value ov);
  SWIGRUNTIME octave_swig_type *swig_value_deref(const octave_base_value &ov);
}

#ifdef SWIG_DIRECTORS
SWIGRUNTIME void swig_acquire_ownership(void *vptr);
SWIGRUNTIME void swig_acquire_ownership_array(void *vptr);
SWIGRUNTIME void swig_acquire_ownership_obj(void *vptr, int own);
#endif

SWIGRUNTIME octave_value SWIG_Octave_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  int own = (flags &SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;

#ifdef SWIG_DIRECTORS
  Swig::Director *d = Swig::get_rtdir(ptr);
  if (d && Swig::swig_director_get_self(d))
    return Swig::swig_director_get_self(d)->as_value();
#endif
  return Swig::swig_value_ref(new octave_swig_type(ptr, type, own));
}

SWIGRUNTIME int SWIG_Octave_ConvertPtrAndOwn(octave_value ov, void **ptr, swig_type_info *type, int flags, int *own) {
  if (ov.is_cell() && ov.rows() == 1 && ov.columns() == 1)
    ov = ov.cell_value()(0);
  if (!ov.is_defined() ||
      (ov.is_matrix_type() && ov.rows() == 0 && ov.columns() == 0) ) {
    if (ptr)
      *ptr = 0;
    return SWIG_OK;
  }
  if (ov.type_id() != octave_swig_ref::static_type_id())
    return SWIG_ERROR;
  octave_swig_ref *osr = static_cast < octave_swig_ref *>(ov.internal_rep());
  octave_swig_type *ost = osr->get_ptr();
  void *vptr = ost->cast(type, own, flags);
  if (!vptr)
    return SWIG_ERROR;
  if (ptr)
    *ptr = vptr;
  return SWIG_OK;
}
