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

// For backward compatibility only
#define SWIG_POINTER_EXCEPTION  0
#define SWIG_arg_fail(arg)      0

// Runtime API implementation

#include <map>
#include <vector>
#include <string>

SWIGRUNTIME mxArray* SWIG_Matlab_NewPointerObj(void *ptr, swig_type_info *type, int flags) {
  mxArray* pm_command = mxCreateString("_swigCreate");
  mxArray* pm;
#if 0
  const char* classname = type->name+3;   /* FIXME: Hack to dereferece pointer */
  char matlab_classname[1024];
#if defined(_MSC_VER) || defined(__BORLANDC__) || defined(_WATCOM)
  _snprintf(matlab_classname,sizeof(matlab_classname)-1,"%s.%s",SWIG_pkg_name,classname);
#else
  snprintf(matlab_classname,sizeof(matlab_classname),"%s.%s",SWIG_pkg_name,classname);
#endif

#else
  const char * matlab_classname;
  if (type->clientdata)
        matlab_classname = (const char *)type->clientdata;
  else {
       // TODO do we really want this? it's a fall-back for non-package types (e.g pointer-to-float)
       matlab_classname = type->name+3;    /* FIXME: Hack to dereference pointer */
       mexWarnMsgIdAndTxt("SWIG:NewPointerObj","NewPointerObj failed. clientdata NULL. guessed %s", matlab_classname);
  }       
#endif

  mxArray* ex = mexCallMATLABWithTrap(1,&pm,1,&pm_command,matlab_classname);

  /* Hack hack */
  if(ex){
    // the above failed, so let's just create a SwigRef
    mxDestroyArray(ex);
    ex = mexCallMATLABWithTrap(1,&pm,0,0,"SwigRef");
  }

  if(ex) mexErrMsgIdAndTxt("SWIG:NewPointerObj","mexCallMATLABWithTrap failed for %s",type->name);
  mxDestroyArray(pm_command);

  mxArray* pm_type = mxCreateString(type->name);
  mxSetProperty(pm,0,"swigType",pm_type);
  mxDestroyArray(pm_type);

  mxArray *pm_ptr = mxCreateNumericMatrix(1,1,mxUINT64_CLASS, mxREAL);
  *(uint64_T *)mxGetData(pm_ptr) = (uint64_T)ptr;
  if(!pm_ptr) mexErrMsgIdAndTxt("SWIG:NewPointerObj","mxCreateNumericMatrix failed");
  mxSetProperty(pm,0,"swigCPtr",pm_ptr);
  mxDestroyArray(pm_ptr);

  bool own = (flags & SWIG_POINTER_OWN) ? SWIG_POINTER_OWN : 0;
  mxArray* pm_own = mxCreateLogicalScalar(own);  
  if(!pm_own) mexErrMsgIdAndTxt("SWIG:NewPointerObj","mxCreateLogicalScalar failed");
  mxSetProperty(pm,0,"swigOwn",pm_own);
  mxDestroyArray(pm_own);

  return pm;
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
  if (ret == SWIG_ERROR)
    return ret;

  /* Get ownership marker */
  mxArray *pm_own = mxGetProperty(pm,0,"swigOwn");
  if(!pm_own || !mxIsLogicalScalar(pm_own)){
    ret = SWIG_ERROR;
  } else {
    if(own) *own = mxIsLogicalScalarTrue(pm_own);
  }
  if(pm_own) mxDestroyArray(pm_own);
  if (ret == SWIG_ERROR)
    return ret;

  /* Set ownership marker to false? */
  if(flags & SWIG_POINTER_DISOWN){
    mxArray* pm_own = mxCreateLogicalScalar(false);
    mxSetProperty(pm,0,"swigOwn",pm_own);
    mxDestroyArray(pm_own);
  }

  /* Get type */
  mxArray *pm_type = mxGetProperty(pm,0,"swigType");
  char type_str[1024];
  if(!pm_type || !mxIsChar(pm_type)){
    ret = SWIG_ERROR;
  } else if (mxGetString(pm_type, type_str, 1024)) {
      ret = SWIG_ERROR;
  } else if (!SWIG_TypeCheck(type_str, type)) {
      ret = SWIG_ERROR;
  }
  if(pm_type) mxDestroyArray(pm_type);
  return ret;
}

SWIGRUNTIME swig_module_info *SWIG_Matlab_GetModule(void *clientdata) {
  swig_module_info *pointer = 0;
  return pointer;
}

SWIGRUNTIME void SWIG_Matlab_SetModule(void *clientdata, swig_module_info *pointer) {
}

/* HACK HACK */
#define SWIG_Matlab_SetConstant(dummy1,dummy2,pm) (pm)
