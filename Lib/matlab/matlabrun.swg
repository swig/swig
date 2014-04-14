SWIGRUNTIME bool SWIG_check_num_args(const char *func_name, int num_args, int max_args, int min_args, int varargs) {
  if (num_args > max_args && !varargs)
    mexWarnMsgIdAndTxt("SWIG","function %s takes at most %i arguments", func_name, max_args);
  else if (num_args < min_args)
    mexWarnMsgIdAndTxt("SWIG","function %s requires at least %i arguments", func_name, min_args);
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

// For backward compatibility only
#define SWIG_POINTER_EXCEPTION  0
#define SWIG_arg_fail(arg)      0

// Runtime API implementation

#include <map>
#include <vector>
#include <string>

SWIGRUNTIME mxArray* SWIG_Matlab_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  mexErrMsgIdAndTxt("SWIG:NotImplemented","type->str = %s, type->name = %s",type==0 ? "n/a" : type->str,type==0 ? "n/a" : type->name);
  mxArray* pm_command = mxCreateString("_swigCreate");
  mxArray *pm_ptr = mxCreateNumericMatrix(1,1,mxUINT64_CLASS, mxREAL);
  *(uint64_T *)mxGetData(pm_ptr) = (uint64_T)ptr;
  bool own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;
  mxArray* pm_own = mxCreateLogicalScalar(own);  
  mxArray* prhs[3] = {pm_command,pm_ptr,pm_own};
  mxArray* plhs[1];
  mexCallMATLABWithTrap(1,plhs,3,prhs,type->str);
  mxDestroyArray(pm_ptr);
  mxDestroyArray(pm_own);
  mxDestroyArray(pm_command);
  return plhs[0];
}

SWIGRUNTIME int SWIG_Matlab_ConvertPtrAndOwn(mxArray* pm, void **ptr, swig_type_info *type, int flags, int *own) {
  /* Return value */
  int ret = SWIG_OK;

  /* Get pointer, represented as a uint64_T scalar */
  mxArray *pm_ptr = mxGetProperty(pm,0,"swigCPtr");
  if(!pm_ptr || mxGetNumberOfElements(pm_ptr) != 1 || mxGetClassID(pm_ptr) != mxUINT64_CLASS || mxIsComplex(pm_ptr)){
    ret = SWIG_ERROR;
  } else {
    if(ptr) *ptr = (void*)(*(uint64_T*)mxGetData(pm_ptr));
  }
  if(pm_ptr) mxDestroyArray(pm_ptr);

  /* Get ownership marker */
  mxArray *pm_own = mxGetProperty(pm,0,"swigOwn");
  if(!pm_own || !mxIsLogicalScalar(pm_own)){
    ret = SWIG_ERROR;
  } else {
    if(own) *own = mxIsLogicalScalarTrue(pm_own);
  }
  if(pm_own) mxDestroyArray(pm_own);

  return ret;
}

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *clientdata) {
  swig_module_info *pointer = 0;
  return pointer;
}

SWIGRUNTIME void SWIG_Matlab_SetModule(void *clientdata, swig_module_info *pointer) {
}
