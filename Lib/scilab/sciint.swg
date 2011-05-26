/*
 * C-type: int
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(int), "header", fragment="SWIG_SciDouble_AsInt") {
#define SWIG_AsVal_int(scilabValue, valuePointer) SWIG_SciDouble_AsInt(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment(SWIG_AsVal_frag(size_t), "header", fragment="SWIG_SciDouble_AsInt") {
#define SWIG_AsVal_size_t(scilabValue, valuePointer) SWIG_SciDouble_AsInt(pvApiCtx, scilabValue, (int*)valuePointer, fname)
}
%fragment("SWIG_SciDouble_AsInt", "header", fragment="SWIG_SciDouble_AsDouble") {
SWIGINTERN int
SWIG_SciDouble_AsInt(void *_pvApiCtx, int _iVar, int *_piValue, char *_fname) {
  double dblValue = 0.0;
  if(SWIG_SciDouble_AsDouble(_pvApiCtx, _iVar, &dblValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_piValue = (int) dblValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(int), "header", fragment="SWIG_SciDouble_FromInt") {
#define SWIG_From_int(value) SWIG_SciDouble_FromInt(pvApiCtx, $result, value)
}
%fragment(SWIG_From_frag(size_t), "header", fragment="SWIG_SciDouble_FromInt") {
#define SWIG_From_size_t(value) SWIG_SciDouble_FromInt(pvApiCtx, $result, (int)value)
}
%fragment("SWIG_SciDouble_FromInt", "header") {
SWIGINTERN int
SWIG_SciDouble_FromInt(void *_pvApiCtx, int _iVarOut, int _iValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _iValue;
  int iRowsOut = 1;
  int iColsOut = 1;

  sciErr = createMatrixOfDouble(_pvApiCtx, Rhs + _iVarOut, iRowsOut, iColsOut, &dblDoubleValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}
}
/*
 * C-type: int[ANY]
 * Scilab type: int32 vector
 */
%fragment("SWIG_SciInt32_AsIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt32_AsIntArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, int **_piValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iPrec = 0;
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
  if (iType != sci_ints) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT32) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger32(_pvApiCtx, piAddrVar, _iRows, _iCols, _piValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciInt32_FromIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt32_FromIntArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, const int *_piData) {
  SciErr sciErr;

  sciErr = createMatrixOfInteger32(_pvApiCtx, Rhs + _iVarOut, _iRows, _iCols, _piData);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}
}
