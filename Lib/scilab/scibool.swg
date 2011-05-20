/*
 * C-type: bool
 * Scilab type: boolean scalar
 */
%fragment(SWIG_AsVal_frag(bool), "header", fragment="SWIG_SciBoolean_AsBool") {
#define SWIG_AsVal_bool(scilabValue, valuePointer) SWIG_SciBoolean_AsBool(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SWIG_SciBoolean_AsBool", "header") {
SWIGINTERN int
SWIG_SciBoolean_AsBool(void *_pvApiCtx, int _iVar, bool *_pbValue, char *_fname) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isBooleanType(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A boolean expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarBoolean(_pvApiCtx, piAddrVar, (int*)_pbValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(bool), "header", fragment="SWIG_SciBoolean_FromBool") {
#define SWIG_From_bool(value) SWIG_SciBoolean_FromBool(pvApiCtx, $result, value)
}
%fragment("SWIG_SciBoolean_FromBool", "header") {
SWIGINTERN int
SWIG_SciBoolean_FromBool(void *_pvApiCtx, int _iVarOut, bool _bValue) {
  int iRet = 0;

  iRet = createScalarBoolean(_pvApiCtx, Rhs + _iVarOut, _bValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}
}

/*
 * C-type: bool[]
 * Scilab type: boolean vector (but converted to int first because can not cast bool** to int **
 */
%fragment("SWIG_SciBoolean_AsIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_AsIntArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, int **_piValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isBooleanType(_pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfBoolean(_pvApiCtx, piAddrVar, _iRows, _iCols, _piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  } else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
