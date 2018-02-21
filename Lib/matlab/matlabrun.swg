/* Last error */
static int SWIG_lasterror_code = 0;
static char SWIG_lasterror_msg[65536];
SWIGRUNTIME void SWIG_Error(int code, const char *format, ...) {
  SWIG_lasterror_code = code;
  va_list arg;
  va_start(arg, format);
  vsnprintf(SWIG_lasterror_msg, sizeof(SWIG_lasterror_msg), format, arg);
  va_end(arg);
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

SWIGRUNTIME int SWIG_check_num_args(const char *func_name, int num_args, int max_args, int min_args, int varargs) {
  if (num_args > max_args && !varargs) {
    SWIG_Error(SWIG_RuntimeError, "function %s takes at most %i arguments", func_name, max_args);
  } else if (num_args < min_args) {
    SWIG_Error(SWIG_RuntimeError, "function %s requires at least %i arguments", func_name, min_args);
  } else {
    return 1;
  }
  return 0;
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

#define SWIG_GetModule(clientdata)                      SWIG_Matlab_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)             SWIG_Matlab_SetModule(pointer);
#define SWIG_MODULE_CLIENTDATA_TYPE void*

#define Matlab_Error_Occurred() 0
#define SWIG_Matlab_AddErrorMsg(msg) {;}

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *clientdata);
SWIGRUNTIME void SWIG_Matlab_SetModule(swig_module_info *pointer);

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0
#define SWIG_arg_fail(arg)      0

/* Pointer to C/C++ object, including type information and reference counters */
typedef struct SwigPtr {
  void *ptr;
  swig_type_info *type;
  int own;
  void *self;
  struct SwigPtr* next;
} SwigPtr;
static swig_module_info *saved_swig_module = 0;

/* Add new pointer object to the memory allocator
   Returns the location of the new element by reference and a return flag by value.
 */
int SWIG_Matlab_NewPointer(SwigPtr** swig_ptr, void *ptr, swig_type_info *type, int own) {
  /* Check input arguments */
  if (!swig_ptr || !type) return 1;

  /* Allocate memory */
  SwigPtr *obj=(SwigPtr *)malloc(sizeof(SwigPtr));
  if (!obj) return 1;

  /* Initialize object */
  obj->ptr = ptr;
  obj->type = type;
  obj->own = own;
  obj->self = obj;
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

  /* Clear and free */
  void* ret = p->own ? p->ptr : 0;
  p->ptr=0;
  p->type=0;
  p->own=0;
  p->self=0;
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

SWIGRUNTIME int
SWIG_Matlab_CallInterp(int nlhs, mxArray *plhs[], int nrhs,
                       mxArray *prhs[], const char *functionName) {
#ifdef HAVE_OCTAVE
  return mexCallMATLAB(nlhs, plhs, nrhs, prhs, functionName);
#else
  mxArray* ex = mexCallMATLABWithTrap(nlhs, plhs, nrhs, prhs, functionName);
  if (ex) {
    mxDestroyArray(ex);
    return 1;
  } else {
    return 0;
  }
#endif
}

SWIGRUNTIME mxArray*
SWIG_Matlab_CallInterpEx(int nlhs, mxArray *plhs[], int nrhs,
                       mxArray *prhs[], const char *functionName) {
#ifdef HAVE_OCTAVE
  int flag = mexCallMATLAB(nlhs, plhs, nrhs, prhs, functionName);
  if (flag) {
    mexErrMsgIdAndTxt("SWIG:CallInterpEx","Not implemented for Octave");
  }
  return 0;
#else
  return mexCallMATLABWithTrap(nlhs, plhs, nrhs, prhs, functionName);
#endif
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Matlab_ConvertPacked(mxArray* SWIGUNUSEDPARM(pm), void* SWIGUNUSEDPARM(ptr), size_t SWIGUNUSEDPARM(sz), swig_type_info* SWIGUNUSEDPARM(ty)) {
  mexErrMsgIdAndTxt("SWIG:ConvertPacked","Not implemented");
  return SWIG_ERROR;
}

/* Runtime API implementation */
SWIGRUNTIME mxArray* SWIG_Matlab_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  /* Ownership? */
  int own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;

  /* Allocate a pointer object */
  SwigPtr* swig_ptr = 0;
  if (SWIG_Matlab_NewPointer(&swig_ptr, ptr, type, own)) {
    mexErrMsgIdAndTxt("SWIG:NewPointerObj","Cannot allocate pointer");
  }

  /* Create a SwigRef instance */
  mxArray* pm = 0;
  int ex = SWIG_Matlab_CallInterp(1, &pm, 0, 0, "SwigRef");
  if (ex) mexErrMsgIdAndTxt("SWIG:NewPointerObj", "Cannot create SwigRef instance");

  /* Set pointer property */
  mxArray *pm_ptr = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
  *(uint64_T *)mxGetData(pm_ptr) = (uint64_T)swig_ptr;
  if(!pm_ptr) mexErrMsgIdAndTxt("SWIG:NewPointerObj", "mxCreateNumericMatrix failed");

  mxArray *rhs[2] = {pm, pm_ptr};
  mexCallMATLAB(0, 0, 2, rhs, "SwigSet");
  mxDestroyArray(pm_ptr);

  /* Create a proxy class of the desired type */
  if (type->clientdata) {
    const char* matlab_classname = (const char *)type->clientdata;
    mxArray* pm_test = 0;
    ex = SWIG_Matlab_CallInterp(1, &pm_test, 1, &pm, matlab_classname);
    if (ex) {
      mexWarnMsgIdAndTxt("SWIG:NewPointerObj",
                         "NewPointerObj problem. creating SwigRef as opposed to %s", matlab_classname);
    } else {
      mxDestroyArray(pm);
      pm = pm_test;
    }
  }

  return pm;
}

/* Create a new packed object */

SWIGRUNTIMEINLINE mxArray*
SWIG_Matlab_NewPackedObj(void* SWIGUNUSEDPARM(ptr), size_t SWIGUNUSEDPARM(sz), swig_type_info* SWIGUNUSEDPARM(type)) {
  mexErrMsgIdAndTxt("SWIG:NewPackedOb","Not implemented");
  return 0;
}

SWIGRUNTIME int SWIG_Matlab_isOwned(mxArray* pm) {
/* Get index, represented as a uint64_T scalar */
  mxArray *pm_ptr;
  mexCallMATLAB(1, &pm_ptr, 1, &pm, "SwigGet");
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
  mxArray *pm_ptr;
  mexCallMATLAB(1, &pm_ptr, 1, &pm, "SwigGet");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 ||
     mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)) {
    if(pm_ptr) mxDestroyArray(pm_ptr);
    return 0;
  }
  SwigPtr* p = (SwigPtr*)(*(uint64_T*)mxGetData(pm_ptr));
  mxDestroyArray(pm_ptr);

  /* Consistency check */
  if (p->self != p) return 0;

  /* Get pointer object */
  return p;
}

SWIGRUNTIME int SWIG_Matlab_ConvertPtrAndOwn(mxArray* pm, void **ptr, swig_type_info *type, int flags, int *own) {
  /* Get index, represented as a uint64_T scalar */
  mxArray *pm_ptr;
  mexCallMATLAB(1, &pm_ptr, 1, &pm, "SwigGet");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 ||
     mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)){
    if(pm_ptr) mxDestroyArray(pm_ptr);
    return SWIG_ERROR;
  }
  SwigPtr* swig_ptr = (SwigPtr*)(*(uint64_T*)mxGetData(pm_ptr));
  mxDestroyArray(pm_ptr);

  /* Get pointer object */
  if (!swig_ptr) return SWIG_ERROR;

  swig_cast_info *tc;
  int same_type = 0;
  SwigPtr* p=swig_ptr;
  while (p) {
    /* Loop over types */
    swig_type_info *p_type = p->type;

    /* No type cast needed */
    if (p_type==type || !type) {
      same_type = 1;
      break;
    }

    /* Check if type conversion is possible */
    tc = SWIG_TypeCheck(p_type->name, type);
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

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *SWIGUNUSEDPARM(clientdata)) {
  if (!saved_swig_module) {
    /* First call for this module, fetch pointer from MATLAB */
    mxArray* mem = 0;
    int flag = mexCallMATLAB(1, &mem, 0, 0, "SwigMem");
    if (flag || !mem) mexErrMsgIdAndTxt("SWIG:GetModule", "Cannot call SwigMem");
    /* On first call, mem is an empty matrix */
    if (mxGetNumberOfElements(mem)!= 0) {
      if (!mxIsStruct(mem)) {
        mexErrMsgIdAndTxt("SWIG:GetModule", "Corrupted memory");
      }
      mxArray *module = mxGetField(mem, 0,
        "swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME);
      if (module && mxGetNumberOfElements(module) == 1 && mxGetClassID(module) == mxUINT64_CLASS && !mxIsComplex(module)) {
        /* Cast memory as a pointer */
        saved_swig_module = (swig_module_info*)(*(uint64_T*)mxGetData(module));
      }
    }
    mxDestroyArray(mem);
  }
  return saved_swig_module;
}

SWIGRUNTIME void SWIG_Matlab_SetModule(swig_module_info *pointer) {
  mxArray* mem = 0;
  const char *fields[1] = {"swig_runtime_data_type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME};
  int flag = mexCallMATLAB(1, &mem, 0, 0, "SwigMem");
  if (flag || !mem) mexErrMsgIdAndTxt("SWIG:SetModule", "Cannot call SwigMem");
  /* Under normal circumstances, swigMem is an empty matrix */
  /* but is not required to be for a valid call to SWIG_Matlab_SetModule() */
  if (mxGetNumberOfElements(mem) == 0) {
    mxDestroyArray(mem);
    mem = mxCreateStructMatrix(1,1,1,fields);
    if(!mem) mexErrMsgIdAndTxt("SWIG:SetModule","mxCreateStructMatrix failed");
    mxArray *module = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    if(!module) mexErrMsgIdAndTxt("SWIG:SetModule","mxCreateNumericMatrix failed");
    *(uint64_T *)mxGetData(module) = (uint64_T)pointer;
    mxSetField(mem, 0, fields[0], module);
  } else {
    int nfields = 0;
    int fieldNum = 0;
    /* Add to existing mem if not the same */
    if (!mxIsStruct(mem)) {
      mexErrMsgIdAndTxt("SWIG:SetModule", "Corrupted memory");
    }
    nfields = mxGetNumberOfFields(mem);
    /* Check if same type table */
    int ii;
    for (ii=0; ii<nfields; ++ii){
      if(strcmp(mxGetFieldNameByNumber(mem, ii), fields[0]) == 0) {
        mxDestroyArray(mem);
        return;
      }
    }
    fieldNum = mxAddField(mem, fields[0]);
    if (fieldNum < 0) mexErrMsgIdAndTxt("SWIG:SetModule", "Error adding field to SwigMem");
    mxArray *module = mxCreateNumericMatrix(1, 1, mxUINT64_CLASS, mxREAL);
    if(!module) mexErrMsgIdAndTxt("SWIG:SetModule","mxCreateNumericMatrix failed");
    *(uint64_T *)mxGetData(module) = (uint64_T)pointer;
    mxSetFieldByNumber(mem, 0, fieldNum, module);
  }
  /* Set variable in SwigMem */
  flag = mexCallMATLAB(0, 0, 1, &mem, "SwigMem");
  mxDestroyArray(mem);
  if (flag) {
    mexErrMsgIdAndTxt("SWIG:SetModule", "Could not set variable in SwigMem.\n");
  }
  saved_swig_module = pointer;
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
