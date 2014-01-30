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
  int iVarOut = SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  if (createScalarDouble(pvApiCtx, iVarOut, (double)_flValue))
    return SWIG_ERROR;
  return iVarOut;
}
}
