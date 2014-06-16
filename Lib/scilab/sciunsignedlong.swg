/*
 * C-type: unsigned long
 * Scilab type: see unsigned int
 */

%fragment(SWIG_AsVal_frag(unsigned long), "header", fragment="SWIG_UnsignedInt_AsUnsignedLong") {
#define SWIG_AsVal_unsigned_SS_long(scilabValue, valuePointer) SWIG_UnsignedInt_AsUnsignedLong(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_UnsignedInt_AsUnsignedLong", "header", fragment=SWIG_AsVal_frag(unsigned int)) {
SWIGINTERN int
SWIG_UnsignedInt_AsUnsignedLong(void *_pvApiCtx, SwigSciObject _iVar, unsigned long *_pulValue, char *_fname) {
  unsigned int uiValue = 0;
  if(SWIG_AsVal_unsigned_SS_int(_iVar, &uiValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pulValue = (unsigned long) uiValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned long), "header", fragment="SWIG_UnsignedInt_FromUnsignedLong") {
#define SWIG_From_unsigned_SS_long(scilabValue) SWIG_UnsignedInt_FromUnsignedLong(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_UnsignedInt_FromUnsignedLong", "header", fragment=SWIG_From_frag(unsigned int)) {
SWIGINTERN int
SWIG_UnsignedInt_FromUnsignedLong(void *_pvApiCtx, int _iVarOut, unsigned long _ulValue, char *_fname) {
  return SWIG_From_unsigned_SS_int((unsigned int)_ulValue);
}
}

%fragment("SWIG_SciUint32_FromUnsignedLongArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint32_FromUnsignedLongArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, const unsigned long *_pulValues) {
  SciErr sciErr;
  double *pdValues = NULL;
  int i;

  pdValues = (double*) malloc(_iRows * _iCols * sizeof(double));
  for (i=0; i<_iRows * _iCols; i++) {
    pdValues[i] = _pulValues[i];
  }

  sciErr = createMatrixOfDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, pdValues);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    free(pdValues);
    return SWIG_ERROR;
  }

  free(pdValues);
  return SWIG_OK;
}
}
