/*
 * DOUBLE SCALAR
 */
%fragment(SWIG_AsVal_frag(double), "header", fragment="SWIG_SciDouble_AsDouble") {
%#define SWIG_AsVal_double(scilabValue, valuePointer) SWIG_SciDouble_AsDouble(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_AsDouble", "header") {
SWIGINTERN int
SWIG_SciDouble_AsDouble(void *_pvApiCtx, SwigSciObject _iVar, double *_pdblValue, char *_fname) {
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

%fragment(SWIG_From_frag(double), "header", fragment="SWIG_SciDouble_FromDouble") { 
%#define SWIG_From_double(scilabValue) SWIG_SciDouble_FromDouble(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_FromDouble", "header") {
SWIGINTERN int
SWIG_SciDouble_FromDouble(void *_pvApiCtx, int _iVarOut, double _dblValue, char *_fname) {
  if (createScalarDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _dblValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

/*
 * DOUBLE ARRAY
 */

%fragment("SWIG_SciDouble_AsDoubleArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_AsDoubleArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, double **_pdValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, _iRows, _iCols, _pdValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  }
  else {
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
  sciErr = createMatrixOfDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, _pdblValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
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
