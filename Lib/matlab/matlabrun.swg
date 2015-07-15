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
  SwigPtr* next;
} SwigPtr;
static SwigPtr *swigPtr=0;
static size_t swigPtrSize=0, swigPtrNumAlloc=0;
static char const * storagename = "swig" SWIG_name_d "directorstorage";

/* Linked list of unused elements in swigPtr */
typedef struct SwigUnused {
  size_t ind;
  struct SwigUnused *next;
} SwigUnused;
static SwigUnused *swigUnused=0;

/* Add new pointer object to the memory allocator
   Returns the location of the new element by reference and a return flag by value.
 */
int SWIG_Matlab_NewPointer(size_t* ind_ptr, void *ptr, swig_type_info *type, int own) {
  /* Check input arguments */
  if (!ind_ptr || !type) return 1;
  size_t ind;

  /* If first time encountered, allocate memory (first element null pointer) */
  if (swigPtrNumAlloc==0) {
    swigPtr=(SwigPtr *)malloc(sizeof(SwigPtr));
    if (!swigPtr) return 1;
    swigPtrNumAlloc=swigPtrSize=1;
  }

  if (swigUnused) {
    /* Get a freed object from the stack  */
    ind = swigUnused->ind;
    /* Pop the element from the stack */
    SwigUnused *next = swigUnused->next;
    free(swigUnused);
    swigUnused = next;
  } else {
    /* Add element at the end */
    if (swigPtrSize==swigPtrNumAlloc) {
      /* Increase size of swigPtr */
      SwigPtr *new_mem = (SwigPtr *)realloc(swigPtr, (2*swigPtrNumAlloc)*sizeof(SwigPtr));
      if (!new_mem) return 1;
      swigPtr=new_mem;
      swigPtrNumAlloc *= 2;
    }
    ind = swigPtrSize++;
  }

  /* Increase lock count */
  mexLock();

  /* Initialize object */
  SwigPtr *obj = swigPtr + ind;
  obj->ptr = ptr;
  obj->type = type;
  obj->own = own;
  obj->next = 0;
  
  /* Return memory reference and successful return */
  *ind_ptr = ind;
  return 0;
}

/* Get a pointer object
   Returns a SwigPtr* with the object if successful, otherwise 0
 */
SwigPtr* SWIG_Matlab_GetPointer(size_t ind) {
  if (ind==0 || ind>=swigPtrSize) {
    return 0;
  } else {
    return swigPtr+ind;
  }
}

/* Free pointer object
   Returns a void* with the object to be freed (if any)
 */
void* SWIG_Matlab_DeletePointer(size_t ind) {
  /* Quick return if null pointer? */
  if (ind==0) return 0;

  /* Get pointer */
  SwigPtr* p = SWIG_Matlab_GetPointer(ind);
  if (!p) {
    mexWarnMsgIdAndTxt("SWIG:DeletePointer", "No such element");
    return 0;
  }

  /* Decrease lock count */
  mexUnlock();

  /* Add to list of unused elements */
  void* ret = p->own ? p->ptr : 0;
  p->ptr=0;
  p->type=0;
  p->own=0;
  p->next=0;
  SwigUnused *next = swigUnused;
  swigUnused = (SwigUnused *)malloc(sizeof(SwigUnused));
  swigUnused->ind = ind;
  swigUnused->next = next;
  return ret;
}

/* This should probably be moved somewhere else */
#ifdef __cplusplus
extern "C"
#endif /* cplusplus */
void SWIG_Matlab_ExitFcn(void) {

  /* Free allocated memory for pointers */
  if (swigPtr) {
    free(swigPtr);
    swigPtr=0;
    swigPtrSize=swigPtrNumAlloc=0;
  }

  /* Free stack with indices of unused pointers */
  while (swigUnused) {
    SwigUnused *next = swigUnused->next;
    free(swigUnused);
    swigUnused = next;
  }

}

/* Runtime API implementation */
SWIGRUNTIME mxArray* SWIG_Matlab_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  mxArray* pm_command = mxCreateString("_swigCreate");
  mxArray* pm;
  const char * matlab_classname;
  if (type->clientdata) {
    matlab_classname = (const char *)type->clientdata;
  } else {
    /* TODO do we really want this? it's a fall-back for non-package types (e.g pointer-to-float)
       However, it will fail anyway because the mexCallMATLABWithTrap call will fail 
       (as there'd be no package.float matlab-type)
    */
    matlab_classname = type->name+3;    /* FIXME: Hack to dereference pointer */
    mexWarnMsgIdAndTxt("SWIG:NewPointerObj","NewPointerObj problem. clientdata NULL. guessed %s", matlab_classname);
  }

  mxArray* ex = mexCallMATLABWithTrap(1, &pm, 1, &pm_command, matlab_classname);

  /* Hack hack */
  if(ex){
    /* the above failed, so let's just create a SwigRef */
    mxDestroyArray(ex);
    mexWarnMsgIdAndTxt("SWIG:NewPointerObj","NewPointerObj problem. creating SwigRef as opposed to %s", matlab_classname);
    ex = mexCallMATLABWithTrap(1, &pm, 0, 0,"SwigRef");
  }

  if(ex) mexErrMsgIdAndTxt("SWIG:NewPointerObj","mexCallMATLABWithTrap failed for %s",type->name);
  mxDestroyArray(pm_command);

  /* Ownership? */
  int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;

  /* Allocate a pointer object */  
  size_t ind;
  if (SWIG_Matlab_NewPointer(&ind, ptr, type, own)) {
    mexErrMsgIdAndTxt("SWIG:NewPointerObj","Cannot allocate pointer");
  }

  /* Pass to class */
  mxArray *pm_ind = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  *(uint64_T *)mxGetData(pm_ind) = (uint64_T)ind;
  if(!pm_ind) mexErrMsgIdAndTxt("SWIG:NewPointerObj","mxCreateNumericMatrix failed");
  mxSetProperty(pm, 0, "swigInd", pm_ind);
  mxDestroyArray(pm_ind);
  
  return pm;
}

SWIGRUNTIME int SWIG_Matlab_isOwned(mxArray* pm) {
/* Get index, represented as a uint64_T scalar */
  mxArray *pm_ind = mxGetProperty(pm, 0, "swigInd");
  if(!pm_ind || mxGetNumberOfElements(pm_ind) != 1 ||
     mxGetClassID(pm_ind) != mxUINT64_CLASS || mxIsComplex(pm_ind)){
    if(pm_ind) mxDestroyArray(pm_ind);
    return SWIG_ERROR;
  }
  size_t ind = (size_t)(*(uint64_T*)mxGetData(pm_ind));
  mxDestroyArray(pm_ind);

  /* Get pointer object */
  SwigPtr* p = SWIG_Matlab_GetPointer(ind);

  if (!p) {
    return 0;
  }
  return p->own;
}

SWIGRUNTIME SwigPtr* SWIG_Matlab_getSwigPtr(mxArray* pm) {
/* Get index, represented as a uint64_T scalar */
  mxArray *pm_ind = mxGetProperty(pm, 0, "swigInd");
  if(!pm_ind || mxGetNumberOfElements(pm_ind) != 1 ||
     mxGetClassID(pm_ind) != mxUINT64_CLASS || mxIsComplex(pm_ind)){
    if(pm_ind) mxDestroyArray(pm_ind);
    return 0;
  }
  size_t ind = (size_t)(*(uint64_T*)mxGetData(pm_ind));
  mxDestroyArray(pm_ind);

  /* Get pointer object */
  return SWIG_Matlab_GetPointer(ind);
}

SWIGRUNTIME int SWIG_Matlab_ConvertPtrAndOwn(mxArray* pm, void **ptr, swig_type_info *type, int flags, int *own) {
  /* Get index, represented as a uint64_T scalar */
  mxArray *pm_ind = mxGetProperty(pm, 0, "swigInd");
  if(!pm_ind || mxGetNumberOfElements(pm_ind) != 1 ||
     mxGetClassID(pm_ind) != mxUINT64_CLASS || mxIsComplex(pm_ind)){
    if(pm_ind) mxDestroyArray(pm_ind);
    return SWIG_ERROR;
  }
  size_t ind = (size_t)(*(uint64_T*)mxGetData(pm_ind));
  mxDestroyArray(pm_ind);

  /* Get pointer object */
  SwigPtr* p = SWIG_Matlab_GetPointer(ind);
  if (!p) {
    mexWarnMsgIdAndTxt("SWIG:ConvertPtrAndOwn", "No such element");
    return 0;
  }

  swig_cast_info *tc;
  while (p) {
    /* Get data */
    if (ptr) *ptr = p->ptr;
    if (own) *own = p->own;
    swig_type_info *p_type = p->type;
    
    /* Set ownership marker to false? */
    if(flags & SWIG_POINTER_DISOWN){
      SWIG_Matlab_DeletePointer(ind);
    }

    /* No type cast needed */
    if (p_type==type || !type) return SWIG_OK;


    /* Check if type conversion is possible */
    tc = SWIG_TypeCheckStruct(p_type, type);
    if (tc) break;
    p = p->next;
  }

  if (!tc) return SWIG_ERROR;

  /* Do type-cast (but only if non-zero pointer, otherwise it's trivial) */
  if (ptr) {
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
