/*
 * DOUBLE SCALAR
 */
%fragment(SWIG_AsVal_frag(double), "header", fragment="SwigScilabDoubleToDouble") {
#define SWIG_AsVal_double(scilabValue, valuePointer) SwigScilabDoubleToDouble(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment(SWIG_From_frag(double), "header", fragment="SwigScilabDoubleFromDouble") {
#define SWIG_From_double(value) SwigScilabDoubleFromDouble(pvApiCtx, $result, value)
}

%fragment("SwigScilabDoubleToDouble", "header") {
SWIGINTERN int
SwigScilabDoubleToDouble(void *_pvApiCtx, int _iVar, double *_pdblValue, char *_fname) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isDoubleType(_pvApiCtx, piAddrVar) || isVarComplex(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarDouble(_pvApiCtx, piAddrVar, _pdblValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment("SwigScilabDoubleFromDouble", "header") {
SWIGINTERN int
SwigScilabDoubleFromDouble(void *_pvApiCtx, int _iVarOut, double _dblValue) {
  int iRet;

  iRet = createScalarDouble(_pvApiCtx, Rhs + _iVarOut, _dblValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}
}

/*
 * DOUBLE ARRAY
 */
%fragment("SwigScilabDoubleToDoubleArray", "header") {
SWIGINTERN int
SwigScilabDoubleToDoubleArray(void *_pvApiCtx, int _iVar, double **_pdblDoubleValue, char *_fname) {
  SciErr sciErr;
  int iRows = 0;
  int iCols = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, &iRows, &iCols, _pdblDoubleValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  } else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciDouble_AsDoubleArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_AsDoubleArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, double **_pdblDoubleValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, _iRows, _iCols, _pdblDoubleValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  } else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciDouble_FromDoubleArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_FromDoubleArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, double *_pdblValue) {
  SciErr sciErr;

  sciErr = createMatrixOfDouble(_pvApiCtx, Rhs + _iVarOut, _iRows, _iCols, _pdblValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }

  return Rhs + _iVarOut;
}
}
