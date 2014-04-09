/* -----------------------------------------------------------------------------
 * Scilab support runtime
 * -----------------------------------------------------------------------------*/

/* Scilab version macro */

#ifndef SWIG_SCILAB_VERSION_MIN
#define SWIG_SCILAB_VERSION_MIN(major, minor, maintenance) \
  ((SCI_VERSION_MAJOR << 16) + (SCI_VERSION_MINOR << 8) + SCI_VERSION_MAINTENANCE \
  >= ((major) << 16) + ((minor) << 8) + maintenance)
#endif


/* Scilab standard headers */

#ifdef __cplusplus
extern "C" {
#endif
#if !SWIG_SCILAB_VERSION_MIN(5, 4, 0)
#define __USE_DEPRECATED_STACK_FUNCTIONS__
#include "stack-c.h"
#endif
#include "MALLOC.h"
#include "Scierror.h"
#include "api_scilab.h"
#include "localization.h"
#include "freeArrayOfString.h"
#ifdef __cplusplus
}
#endif

#undef Max
#undef Min


/* Function name management functions */

#include <stdlib.h>
static char* fname = NULL;
static char* SWIG_Scilab_GetFname(void) {
  return fname;
}
static void SWIG_Scilab_SetFname(char* _fname) {
  if (fname != NULL) {
    free(fname);
  }
  fname = strdup(_fname);
}


/* Argument management functions */

#if SWIG_SCILAB_VERSION_MIN(5, 4, 0)
#define SWIG_CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument) CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument)
#define SWIG_CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument) CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument)
#define SWIG_NbInputArgument(pvApiCtx) nbInputArgument(pvApiCtx)
#define SWIG_AssignOutputArgument(pvApiCtx, outputArgumentPos, argumentPos) AssignOutputVariable(pvApiCtx, outputArgumentPos) = argumentPos
#else
#define SWIG_CheckInputArgument(pvApiCtx, minInputArgument, maxInputArgument) CheckRhs(minInputArgument, maxInputArgument)
#define SWIG_CheckOutputArgument(pvApiCtx, minOutputArgument, maxOutputArgument) CheckLhs(minOutputArgument, maxOutputArgument)
#define SWIG_NbInputArgument(pvApiCtx) Rhs
#define SWIG_AssignOutputArgument(pvApiCtx, outputArgumentPos, argumentPos) LhsVar(outputArgumentPos) = argumentPos
#endif

typedef int SwigSciObject;

static int outputPosition = -1;
static int SWIG_Scilab_GetOutputPosition(void) {
  return outputPosition;
}
static int SWIG_Scilab_GetOutputPositionAndReset(void) {
  int returnValue = outputPosition;
  outputPosition = -1; /* Set as read */
  return returnValue;
}
static void SWIG_Scilab_SetOutputPosition(int _outputPosition) {
  outputPosition = _outputPosition;
}

SWIGRUNTIME int
SWIG_Scilab_SetOutput(void *_pvApiCtx, SwigSciObject _output) {
  int outputPosition = SWIG_Scilab_GetOutputPositionAndReset();
  if (outputPosition < 0)
      return SWIG_ERROR;
  SWIG_AssignOutputArgument(_pvApiCtx, outputPosition,
    SWIG_NbInputArgument(_pvApiCtx) + outputPosition);
  return SWIG_OK;
}


/* Pointer conversion functions */

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

  if (iType == sci_pointer) {
    sciErr = getPointer(_pvApiCtx, piAddrVar, _pObjValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  }
  else {
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGRUNTIMEINLINE int
SwigScilabPtrFromObject(void *_pvApiCtx, int _iVarOut, void *_object, swig_type_info *_descriptor, int _flags) {
  SciErr sciErr;

  sciErr = createPointer(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, (void *)_object);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGRUNTIME int
SWIG_Scilab_ConvertPacked(void *_pvApiCtx, int _iVar, void *_ptr, int sz, swig_type_info *ty, char *_fname) {
  swig_cast_info *tc;
  int *piAddrVar = NULL;
  char *pstStrings = NULL;
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (getAllocatedSingleString(_pvApiCtx, piAddrVar, &pstStrings)) {
    return SWIG_ERROR;
  }

  /* Pointer values must start with leading underscore */
  if (*pstStrings != '_') {
    return SWIG_ERROR;
  }

  pstStrings++;
  pstStrings = (char*)SWIG_UnpackData(pstStrings, _ptr, sz);

  if (ty) {
    if (!pstStrings) {
      return SWIG_ERROR;
    }
    tc = SWIG_TypeCheck(pstStrings, ty);
    if (!tc) {
      return SWIG_ERROR;
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME int
SWIG_Scilab_NewMemberObj(void *_pvApiCtx, int _iVarOut, void *_ptr, int _sz, swig_type_info *_type) {
  char result[1024];
  char *r = result;

  if ((2*_sz + 1 + strlen(_type->name)) > 1000) {
    return SWIG_ERROR;
  }
  *(r++) = '_';
  r = SWIG_PackData(r, _ptr, _sz);
  strcpy(r, _type->name);

  if (createSingleString(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, &result[0]))
    return SWIG_ERROR;

  return SWIG_OK;
}


/* Error functions */

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
#define SWIG_ErrorType(code) SWIG_Scilab_ErrorType(code)

SWIGINTERN void
SWIG_Scilab_ErrorMsg(int code, const char *msg)
{
  Scierror(999, _("SWIG/Scilab %s: %s\n"), SWIG_Scilab_ErrorType(code), msg);
}

#define SWIG_Error(code, msg) SWIG_Scilab_ErrorMsg(code, msg)

#define SWIG_fail return SWIG_ERROR;

SWIGRUNTIME int
SwigScilabRaiseEx(const char *obj, const char *type, swig_type_info *descriptor) {
  if (type) {
    if (obj)
      Scierror(999, "Exception (%s) occured: %s\n", type, obj);
    else
      Scierror(999, "Exception (%s) occured.\n", type);
  }
}

SWIGRUNTIME int
SwigScilabRaise(const int obj, const char *type, swig_type_info *descriptor) {
  Scierror(999, "Exception (%s) occured.\n", type);
}

#define SWIG_Scilab_Raise(obj, type, descriptor) SwigScilabRaise(obj, type, descriptor)

/*
 *  Pointer utility functions
 */

#ifdef __cplusplus
extern "C"
#endif
int swig_this(char *fname, unsigned long fname_len) {
  void *ptrValue = NULL;
  if (SwigScilabPtrToObject(pvApiCtx, 1, &ptrValue, NULL, 0, fname) == SWIG_OK) {
    SWIG_Scilab_SetOutputPosition(1);
    return SWIG_Scilab_SetOutput(pvApiCtx,
      createScalarDouble(pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + 1,
        (double) (unsigned long) ptrValue));
  }
  else {
    Scierror(999, _("%s: Incorrect value for input argument #%d: The value is not a pointer.\n"), fname, 1);
    return SWIG_ERROR;
  }
}

#ifdef __cplusplus
extern "C"
#endif
int swig_ptr(char *fname, unsigned long fname_len) {
  double dValue = 0;
  int *piAddr;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, 1, &piAddr);
	if(sciErr.iErr) {
		printError(&sciErr, 0);
		return SWIG_ERROR;
	}
  if (getScalarDouble(pvApiCtx, piAddr, &dValue) == 0) {
    if (dValue != (unsigned long)dValue) {
      Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a pointer.\n"), fname, 1);
      return SWIG_ValueError;
    }
    if ((dValue < LONG_MIN) || (dValue > LONG_MAX)) {
      Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a pointer.\n"), fname, 1);
      return SWIG_OverflowError;
    }
    SWIG_Scilab_SetOutputPosition(1);
    return SWIG_Scilab_SetOutput(pvApiCtx,
      SwigScilabPtrFromObject(pvApiCtx, 1, (void *) (unsigned long) dValue, NULL, 0));
  }
  else {
    return SWIG_ERROR;
  }
}

