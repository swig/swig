/*
 * C-type: long
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(long), "header", fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(long)(SwigSciObject _iVar, long *_plValue) {
  double dblValue = 0.0;
  if(SWIG_AsVal_dec(double)(_iVar, &dblValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_plValue = (long) dblValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(long), "header") {
SWIGINTERN int
SWIG_From_dec(long)(long _lValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _lValue;
  int iRowsOut = 1;
  int iColsOut = 1;
  int iVarOut = Rhs + SWIG_Scilab_GetOutputPosition();

  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, &dblDoubleValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return iVarOut;
}
}

/*
 * C-type: unsigned long
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(unsigned long), "header", fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(SwigSciObject _iVar, unsigned long *_pulValue) {
  double dblValue = 0.0;
  if(SWIG_AsVal_dec(double)(_iVar, &dblValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pulValue = (unsigned long) dblValue;
  return SWIG_OK;
}
}


%fragment(SWIG_From_frag(unsigned long), "header") {
SWIGINTERN int
SWIG_From_dec(unsigned long)(unsigned long _ulValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _ulValue;
  int iRowsOut = 1;
  int iColsOut = 1;
  int iVarOut = Rhs + SWIG_Scilab_GetOutputPosition();

  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, &dblDoubleValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return iVarOut;
}
}
