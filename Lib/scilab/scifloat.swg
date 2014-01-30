/*
 * FLOAT SCALAR
 */
%fragment(SWIG_AsVal_frag(float), "header", fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(float)(SwigSciObject _iVar, float *_pfValue) {
  double dblValue = 0.0;
  if(SWIG_AsVal_dec(double)(_iVar, &dblValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pfValue = (float) dblValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(float), "header") {
SWIGINTERN int
SWIG_From_dec(float)(float _flValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _flValue;
  int iRowsOut = 1;
  int iColsOut = 1;
  int iVarOut = SWIG_NbInputArgument(_pvApiCtx) + SWIG_Scilab_GetOutputPosition();

  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, &dblDoubleValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return iVarOut;
}
}
