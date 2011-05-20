/*
 * FLOAT SCALAR
 */
%fragment(SWIG_AsVal_frag(float), "header", fragment="SwigScilabDoubleToFloat") {
#define SWIG_AsVal_float(scilabValue, valuePointer) SwigScilabDoubleToFloat(pvApiCtx, scilabValue, valuePointer, fname)
}

%fragment(SWIG_From_frag(float), "header", fragment="SwigScilabDoubleFromFloat") {
#define SWIG_From_float(value) SwigScilabDoubleFromFloat(pvApiCtx, $result, value)
}

%fragment("SwigScilabDoubleToFloat", "header", fragment="SwigScilabDoubleToDouble") {
SWIGINTERN int
SwigScilabDoubleToFloat(void *_pvApiCtx, int _iVar, float *_pfValue, char *_fname) {
  double dblValue = 0.0;
  if(SwigScilabDoubleToDouble(_pvApiCtx, _iVar, &dblValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pfValue = (float) dblValue;
  return SWIG_OK;
}
}

%fragment("SwigScilabDoubleFromFloat", "header") {
SWIGINTERN int
SwigScilabDoubleFromFloat(void *_pvApiCtx, int _iVarOut, float _flValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _flValue;
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
