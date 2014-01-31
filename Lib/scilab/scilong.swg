/*
 * C-type: long
 * Scilab type: double or int32
 */

%fragment(SWIG_AsVal_frag(long), "header", fragment="SWIG_Int_AsLong") {
%#define SWIG_AsVal_long(scilabValue, valuePointer) SWIG_Int_AsLong(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname());
}
%fragment("SWIG_Int_AsLong", "header", fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
SWIG_Int_AsLong(void *_pvApiCtx, SwigSciObject _iVar, long *_plValue, char *_fname) {
  int iValue = 0.0;
  if(SWIG_AsVal_dec(int)(_iVar, &iValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_plValue = (long) iValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(long), "header", fragment="SWIG_Int_FromLong") {
%#define SWIG_From_long(scilabValue) SWIG_Int_FromLong(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_Int_FromLong", "header", fragment=SWIG_From_frag(int)) {
SWIGINTERN int
SWIG_Int_FromLong(void *_pvApiCtx, int _iVarOut, long _lValue, char *_fname) {
  return SWIG_From_dec(int)((int)_lValue);
}
}

