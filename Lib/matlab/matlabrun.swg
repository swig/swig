SWIGRUNTIME bool SWIG_check_num_args(const char *func_name, int num_args, int max_args, int min_args, int varargs) {
  if (num_args > max_args && !varargs)
    mexWarnMsgIdAndTxt("SWIG:RuntimeError","function %s takes at most %i arguments", func_name, max_args);
  else if (num_args < min_args)
    mexWarnMsgIdAndTxt("SWIG:RuntimeError","function %s requires at least %i arguments", func_name, min_args);
  else
    return true;
  return false;
}

SWIGRUNTIME const char* SWIG_ErrorType(int code) {
  switch (code) {
  case SWIG_MemoryError:
    return "SWIG:MemoryError";
  case SWIG_IOError:
    return "SWIG:IOError";
  case SWIG_RuntimeError:
    return "SWIG:RuntimeError";
  case SWIG_IndexError:
    return "SWIG:IndexError";
  case SWIG_TypeError:
    return "SWIG:TypeError";
  case SWIG_DivisionByZero:
    return "SWIG:DivisionByZero";
  case SWIG_OverflowError:
    return "SWIG:OverflowError";
  case SWIG_SyntaxError:
    return "SWIG:SyntaxError";
  case SWIG_ValueError:
    return "SWIG:ValueError";
  case SWIG_SystemError:
    return "SWIG:SystemError";
  case SWIG_AttributeError:
    return "SWIG:AttributeError";
  }
  return "SWIG:UnknownError";
}

SWIGRUNTIME void SWIG_Error(int code, const char *msg) {
  mexWarnMsgIdAndTxt(SWIG_ErrorType(code),msg);
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

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0
#define SWIG_arg_fail(arg)      0

/* Pointer to C/C++ object, including type information and reference counters */
typedef struct SwigPtr {
  void *ptr;
  swig_type_info *type;
  int own;
  struct SwigPtr* next;
} SwigPtr;
static char const * storagename = "swig" SWIG_name_d "directorstorage";

/* Add new pointer object to the memory allocator
   Returns the location of the new element by reference and a return flag by value.
 */
int SWIG_Matlab_NewPointer(SwigPtr** swig_ptr, void *ptr, swig_type_info *type, int own) {
  /* Check input arguments */
  if (!swig_ptr || !type) return 1;

  /* Allocate memory */
  SwigPtr *obj=(SwigPtr *)malloc(sizeof(SwigPtr));
  if (!obj) return 1;

  /* Increase lock count */
  mexLock();

  /* Initialize object */
  obj->ptr = ptr;
  obj->type = type;
  obj->own = own;
  obj->next = 0;
  
  /* Return memory reference and successful return */
  *swig_ptr = obj;
  return 0;
}

/* Free pointer object
   Returns a void* with the object to be freed (if any)
 */
void* SWIG_Matlab_DeletePointer(SwigPtr* p) {
  /* Quick return if null pointer? */
  if (p==0) return 0;

  /* Decrease lock count */
  mexUnlock();

  /* Clear and free */
  void* ret = p->own ? p->ptr : 0;
  p->ptr=0;
  p->type=0;
  p->own=0;
  p->next=0;
  free(p);
  return ret;
}

/* This should probably be moved somewhere else */
#ifdef __cplusplus
extern "C"
#endif /* cplusplus */
void SWIG_Matlab_ExitFcn(void) {
  /* Unused at the moment */
}

/* Runtime API implementation */
SWIGRUNTIME mxArray* SWIG_Matlab_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  /* Proxy class instance */
  mxArray* pm = 0;

  /* Create a proxy class of the desired type */
  if (type->clientdata) {
    mxArray* pm_command = mxCreateString("_swigCreate");
    const char* matlab_classname = (const char *)type->clientdata;
    mxArray* ex = mexCallMATLABWithTrap(1, &pm, 1, &pm_command, matlab_classname);
    if (ex) {
      pm = 0;
      mexWarnMsgIdAndTxt("SWIG:NewPointerObj",
                         "NewPointerObj problem. creating SwigRef as opposed to %s", matlab_classname);
      mxDestroyArray(ex);
    }
    mxDestroyArray(pm_command);
  }

  /* Fall-back to SwigRef */
  if (!pm) {
    mxArray* ex = mexCallMATLABWithTrap(1, &pm, 0, 0, "SwigRef");
    if(ex) {
      pm = 0;
      mexErrMsgIdAndTxt("SWIG:NewPointerObj",
                        "mexCallMATLABWithTrap failed for %s",type->name);
    }
  }

  /* Ownership? */
  int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;

  /* Allocate a pointer object */  
  SwigPtr* swig_ptr;
  if (SWIG_Matlab_NewPointer(&swig_ptr, ptr, type, own)) {
    mexErrMsgIdAndTxt("SWIG:NewPointerObj","Cannot allocate pointer");
  }

  /* Pass to class */
  mxArray *pm_ptr = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  *(uint64_T *)mxGetData(pm_ptr) = (uint64_T)swig_ptr;
  if(!pm_ptr) mexErrMsgIdAndTxt("SWIG:NewPointerObj", "mxCreateNumericMatrix failed");
  mxSetProperty(pm, 0, "swigPtr", pm_ptr);
  mxDestroyArray(pm_ptr);
  
  return pm;
}

SWIGRUNTIME int SWIG_Matlab_isOwned(mxArray* pm) {
/* Get index, represented as a uint64_T scalar */
  mxArray *pm_ptr = mxGetProperty(pm, 0, "swigPtr");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 ||
     mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)) {
    if(pm_ptr) mxDestroyArray(pm_ptr);
    return SWIG_ERROR;
  }
  SwigPtr* p = (SwigPtr*)(*(uint64_T*)mxGetData(pm_ptr));
  mxDestroyArray(pm_ptr);

  return p ? p->own : 0;
}

SWIGRUNTIME SwigPtr* SWIG_Matlab_getSwigPtr(mxArray* pm) {
/* Get index, represented as a uint64_T scalar */
  mxArray *pm_ptr = mxGetProperty(pm, 0, "swigPtr");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 ||
     mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)) {
    if(pm_ptr) mxDestroyArray(pm_ptr);
    return 0;
  }
  SwigPtr* p = (SwigPtr*)(*(uint64_T*)mxGetData(pm_ptr));
  mxDestroyArray(pm_ptr);

  /* Get pointer object */
  return p;
}

SWIGRUNTIME int SWIG_Matlab_ConvertPtrAndOwn(mxArray* pm, void **ptr, swig_type_info *type, int flags, int *own) {
  /* Get index, represented as a uint64_T scalar */
  mxArray *pm_ptr = mxGetProperty(pm, 0, "swigPtr");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 ||
     mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)){
    if(pm_ptr) mxDestroyArray(pm_ptr);
    return SWIG_ERROR;
  }
  SwigPtr* swig_ptr = (SwigPtr*)(*(uint64_T*)mxGetData(pm_ptr));
  mxDestroyArray(pm_ptr);

  /* Get pointer object */
  if (!swig_ptr) {
    mexWarnMsgIdAndTxt("SWIG:ConvertPtrAndOwn", "No such element");
    return 0;
  }

  swig_cast_info *tc;
  bool same_type = false;
  SwigPtr* p=swig_ptr;
  while (p) {
    /* Loop over types */
    swig_type_info *p_type = p->type;

    /* No type cast needed */
    if (p_type==type || !type) {
      same_type = true;
      break;
    }

    /* Check if type conversion is possible */
    tc = SWIG_TypeCheckStruct(p_type, type);
    if (tc) break;

    /* Check next type */
    p = p->next;
  }

  /* Conversion not possible */
  if (!same_type && !tc) return SWIG_ERROR;

  /* Get data */
  if (ptr) *ptr = p->ptr;
  if (own) *own = p->own;
    
  /* Set ownership marker to false? */
  if(flags & SWIG_POINTER_DISOWN){
    SWIG_Matlab_DeletePointer(swig_ptr);
  }

  /* No type cast needed */
  if (same_type || !ptr) {
    return SWIG_OK;
  }

  /* Do type-cast */
  int newmemory = 0;
  *ptr = SWIG_TypeCast(tc, *ptr, &newmemory);
  if (newmemory == SWIG_CAST_NEW_MEMORY) {
    if (own) {
      *own = *own | SWIG_CAST_NEW_MEMORY;
    } else {
      /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
      mexErrMsgIdAndTxt("SWIG:ConvertPointerObj","SWIG error in converting pointer for type %s. Bad typemap?",type->name);
      return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *clientdata) {
  swig_module_info *pointer = 0;
  return pointer;
}

SWIGRUNTIME void SWIG_Matlab_SetModule(void *clientdata, swig_module_info *pointer) {
}

/* HACK HACK */
#define SWIG_Matlab_SetConstant(dummy1,dummy2,pm) (pm)

#ifdef __cplusplus
#include <streambuf>
#include <iostream>
namespace swig {
  // Stream buffer to allow redirecting output to MATLAB
  class SWIG_Matlab_streambuf : public std::streambuf {
  public:
    SWIG_Matlab_streambuf() {}
  protected:
    virtual int_type overflow(int_type ch) {
      if(ch != traits_type::eof()) {
        mexPrintf("%c", static_cast<char>(ch));
      }
      return ch;
    }
    virtual std::streamsize xsputn(const char* s, std::streamsize num) {
      // Pass straight to mexPrintf without buffering
      mexPrintf("%.*s", static_cast<int>(num), s);
      return num;
    }
  };

  // Instantiation
  static SWIG_Matlab_streambuf SWIG_Matlab_buf;
} // namespace swig
#endif /* cplusplus */
