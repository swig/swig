/*
 * C-type: long
 * Scilab type: double or int32
 */

%fragment(SWIG_AsVal_frag(long), "header", fragment="SWIG_SciDoubleOrInt32_AsLong", fragment="<limits.h>") {
%#define SWIG_AsVal_long(scilabValue, valuePointer) SWIG_SciDoubleOrInt32_AsLong(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname());
}
%fragment("SWIG_SciDoubleOrInt32_AsLong", "header") {
SWIGINTERN int
SWIG_SciDoubleOrInt32_AsLong(void *_pvApiCtx, SwigSciObject _iVar, long *_plValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
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

  if (iType == sci_ints) {
    int iPrec = 0;
    int *piData = NULL;

    sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iPrec != SCI_INT32) {
      Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    sciErr = getMatrixOfInteger32(_pvApiCtx, piAddrVar, &iRows, &iCols, &piData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    *_plValue = (long) *piData;
  }
  else if (iType == sci_matrix) {
    double *pdData = NULL;
    double dValue = 0.0f;

    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    dValue = *pdData;
    if (dValue != floor(dValue)) {
      Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), _fname, _iVar);
      return SWIG_ValueError;
    }
    if ((dValue < LONG_MIN) || (dValue > LONG_MAX)) {
      Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), _fname, _iVar);
      return SWIG_OverflowError;
    }
    *_plValue = (long) dValue;
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
    return SWIG_TypeError;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(long), "header", fragment="SWIG_SciDouble_FromLong") {
%#define SWIG_From_long(scilabValue) SWIG_SciDouble_FromLong(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_FromLong", "header") {
SWIGINTERN int
SWIG_SciDouble_FromLong(void *_pvApiCtx, int _iVarOut, long _lValue, char *_fname) {
  if (createScalarDouble(_pvApiCtx,
    SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, (double) _lValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

