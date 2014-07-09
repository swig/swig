/*
 * DOUBLE SCALAR
 */
%fragment(SWIG_AsVal_frag(double), "header", fragment="SWIG_SciDouble_AsDouble") {
%#define SWIG_AsVal_double(scilabValue, valuePointer) SWIG_SciDouble_AsDouble(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_AsDouble", "header") {
SWIGINTERN int
SWIG_SciDouble_AsDouble(void *_pvApiCtx, SwigSciObject iVar, double *pdblValue, char *_fname) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isDoubleType(_pvApiCtx, piAddrVar) || isVarComplex(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real expected.\n"), _fname, iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(_pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), _fname, iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarDouble(_pvApiCtx, piAddrVar, pdblValue);
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
SWIG_SciDouble_FromDouble(void *_pvApiCtx, int iVarOut, double dblValue, char *_fname) {
  if (createScalarDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + iVarOut, dblValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

/*
 * DOUBLE ARRAY
 */

%fragment("SWIG_SciDouble_AsDoubleArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_AsDoubleArrayAndSize(void *_pvApiCtx, int iVar, int *iRows, int *iCols, double **pdValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar)) {
    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, iRows, iCols, pdValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), _fname, iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment("SWIG_SciDouble_FromDoubleArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_FromDoubleArrayAndSize(void *_pvApiCtx, int iVarOut, int iRows, int iCols, double *pdblValue) {
  SciErr sciErr;
  sciErr = createMatrixOfDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + iVarOut, iRows, iCols, pdblValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_CreateScilabVariable_frag(double), "wrapper") {
SWIGINTERN int
SWIG_CreateScilabVariable_dec(double)(void *_pvApiCtx, const char* psVariableName, const double dVariableValue) {
  SciErr sciErr;
  sciErr = createNamedMatrixOfDouble(_pvApiCtx, psVariableName, 1, 1, &dVariableValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}
