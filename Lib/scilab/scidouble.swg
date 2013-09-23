/*
 * DOUBLE SCALAR
 */
%fragment(SWIG_AsVal_frag(double), "header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(SwigSciObject _iVar, double *_pdblValue) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isDoubleType(pvApiCtx, piAddrVar) || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real expected.\n"), SWIG_Scilab_GetFname(), _iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), SWIG_Scilab_GetFname(), _iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarDouble(pvApiCtx, piAddrVar, _pdblValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(double), "header") {
SWIGINTERN int
SWIG_From_dec(double)(double _dblValue) {
  int iRet;
  int iVarOut = Rhs + SWIG_Scilab_GetOutputPosition();
  iRet = createScalarDouble(pvApiCtx, iVarOut, _dblValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  return iVarOut;
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
%fragment(SWIG_CreateScilabVariable_frag(double), "wrapper") {
SWIGINTERN int
SWIG_CreateScilabVariable_dec(double)(void *_pvApiCtx, const char* _psVariableName, const double _dVariableValue) {
  SciErr sciErr;
  sciErr = createNamedMatrixOfDouble(_pvApiCtx, _psVariableName, 1, 1, &_dVariableValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}
