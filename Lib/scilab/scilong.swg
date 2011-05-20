/*
 * C-type: long
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(long), "header", fragment="SwigScilabDoubleToLong") {
#define SWIG_AsVal_long(scilabValue, valuePointer) SwigScilabDoubleToLong(pvApiCtx, scilabValue, valuePointer, fname)
}

%fragment(SWIG_From_frag(long), "header", fragment="SwigScilabDoubleFromLong") {
#define SWIG_From_long(value) SwigScilabDoubleFromLong(pvApiCtx, $result, value)
}

/*
 * C-type: unsigned long
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(unsigned long), "header", fragment="SwigScilabDoubleToUnsignedLong") {
#define SWIG_AsVal_unsigned_SS_long(scilabValue, valuePointer) SwigScilabDoubleToUnsignedLong(pvApiCtx, scilabValue, valuePointer, fname)
}

%fragment(SWIG_From_frag(unsigned long), "header", fragment="SwigScilabDoubleFromUnsignedLong") {
#define SWIG_From_unsigned_SS_long(value) SwigScilabDoubleFromUnsignedLong(pvApiCtx, $result, value)
}

%fragment("SwigScilabDoubleToLong", "header", fragment="SwigScilabDoubleToDouble") {
SWIGINTERN int
SwigScilabDoubleToLong(void *_pvApiCtx, int _iVar, long *_plValue, char *_fname) {
  double dblValue = 0.0;
  if(SwigScilabDoubleToDouble(_pvApiCtx, _iVar, &dblValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_plValue = (long) dblValue;
  return SWIG_OK;
}
}

%fragment("SwigScilabDoubleToUnsignedLong", "header", fragment="SwigScilabDoubleToDouble") {
SWIGINTERN int
SwigScilabDoubleToUnsignedLong(void *_pvApiCtx, int _iVar, unsigned long *_pulValue, char *_fname) {
  double dblValue = 0.0;
  if(SwigScilabDoubleToDouble(_pvApiCtx, _iVar, &dblValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pulValue = (unsigned long) dblValue;
  return SWIG_OK;
}
}

%fragment("SwigScilabDoubleFromLong", "header") {
SWIGINTERN int
SwigScilabDoubleFromLong(void *_pvApiCtx, int _iVarOut, long _lValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _lValue;
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

%fragment("SwigScilabDoubleFromUnsignedLong", "header") {
SWIGINTERN int
SwigScilabDoubleFromUnsignedLong(void *_pvApiCtx, int _iVarOut, unsigned long _ulValue) {
  SciErr sciErr;
  double dblDoubleValue = (double) _ulValue;
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
