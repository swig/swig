%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) "scirun.swg";

#define %scilabcode %insert("scilab")


%insert(runtime) %{
/* Scilab standard headers */
#ifdef __cplusplus
extern "C" {
#endif
#include "MALLOC.h"
#include "sciprint.h"
#include "Scierror.h"
#include "api_scilab.h"
#include "localization.h"
#include "freeArrayOfString.h"
#ifdef __cplusplus
}
#endif

#undef Max
#undef Min

typedef int SciObject;


/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

SWIGINTERN const char*
SWIG_Scilab_ErrorType(int code) {
  switch(code) {
  case SWIG_MemoryError:
    return "MemoryError";
  case SWIG_IOError:
    return "IOError";
  case SWIG_RuntimeError:
    return "RuntimeError";
  case SWIG_IndexError:
    return "IndexError";
  case SWIG_TypeError:
    return "TypeError";
  case SWIG_DivisionByZero:
    return "ZeroDivisionError";
  case SWIG_OverflowError:
    return "OverflowError";
  case SWIG_SyntaxError:
    return "SyntaxError";
  case SWIG_ValueError:
    return "ValueError";
  case SWIG_SystemError:
    return "SystemError";
  case SWIG_AttributeError:
    return "AttributeError";
  default:
    return "RuntimeError";
  }
}

SWIGINTERN void
SWIG_Scilab_ErrorMsg(int code, const char *mesg)
{
   sciprint(_("SWIG/Scilab Error : %s\n%s"),SWIG_Scilab_ErrorType(code),mesg);
}



#define SWIG_fail                 return SWIG_ERROR;
#define SWIG_ErrorType(code)      SWIG_Scilab_ErrorType(code)
#define SWIG_Error(code, msg)     SWIG_Scilab_ErrorMsg(code,msg)

/* Used for C++ enums */
//#define SWIG_AsVal_int(scilabValue, valuePointer) SWIG_SciDouble_AsInt(pvApiCtx, scilabValue, valuePointer, fname)

SWIGINTERN int
SwigScilabPtrToObject(void *_pvApiCtx, int _iVar, void **_pObjValue, swig_type_info *_descriptor, int _flags, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(_pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_pointer) {
    //Scierror(999, _("%s: Wrong type for input argument #%d: A pointer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getPointer(_pvApiCtx, piAddrVar, _pObjValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGRUNTIMEINLINE int
SwigScilabPtrFromObject(void *_pvApiCtx, int _iVarOut, void *_object, swig_type_info *_descriptor, int _flags) {
  SciErr sciErr;

  sciErr = createPointer(pvApiCtx, Rhs + _iVarOut, (void *)_object);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}

SWIGRUNTIME int
SWIG_Scilab_ConvertPacked(void *_pvApiCtx, int _iVar, void *_ptr, int sz, swig_type_info *ty, char *_fname) {
  swig_cast_info *tc;

  SciErr sciErr;
  int iRows = 0;
  int iCols = 0;
  int iType = 0;
  int *piAddrVar = NULL;
  char *pstStrings = NULL;
  int piLength = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_strings) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  pstStrings = (char *)MALLOC(sizeof(char) * (piLength + 1));
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, (char **)&pstStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  /* Pointer values must start with leading underscore */
  if (*pstStrings != '_') {
    return SWIG_ERROR;
  }
  pstStrings++;
  pstStrings = (char*)SWIG_UnpackData(pstStrings, _ptr, sz);
  if (ty) {
    tc = SWIG_TypeCheck(pstStrings, ty);
    if (!tc) {
      return SWIG_ERROR;
    }
  }
  FREE(pstStrings);
  return SWIG_OK;
}

SWIGRUNTIME int
SWIG_Scilab_NewMemberObj(void *_pvApiCtx, int _iVarOut, void *_ptr, int _sz, swig_type_info *_type) {
  char result[1024];
  char *r = result;

  SciErr sciErr;
  char **pstData = NULL;
  if ((2*_sz + 1 + strlen(_type->name)) > 1000) {
    return SWIG_ERROR;
  }
  *(r++) = '_';
  r = SWIG_PackData(r, _ptr, _sz);
  strcpy(r, _type->name);

  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = strdup(r);

  sciErr = createMatrixOfString(_pvApiCtx, Rhs + _iVarOut, 1, 1, (char **)pstData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  free(pstData[0]);

  return Rhs + _iVarOut;
}

SWIGRUNTIME int
SWIG_Scilab_SetOutput(void *_pvApiCtx, SciObject _output) {
  int outputPosition = SWIG_Scilab_GetOutputPositionAndReset();
  if (outputPosition < 0 || _output < 0) {
      return SWIG_ERROR;
  }
  AssignOutputVariable(_pvApiCtx, outputPosition) = _output;
  return SWIG_OK;
}

#define SWIG_Scilab_Raise(obj, type, desc) SwigScilabRaise(type)

SWIGRUNTIME int
SwigScilabRaise(const char *type) {
  Scierror(999, "An exception of type %s has been thrown.\n", type);
#ifdef __cplusplus
  throw;
#endif
}

%}

//%insert(init) "swiginit.swg"
%init %{
/* -----------------------------------------------------------------------------*
 *  Partial Init method
 * -----------------------------------------------------------------------------*/

SWIGEXPORT int SWIG_init(void) {
%}
