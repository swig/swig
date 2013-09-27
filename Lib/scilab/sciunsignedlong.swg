/*
 * C-type: unsigned long
 * Scilab type: uint32
 */

%fragment(SWIG_AsVal_frag(unsigned long), "header", fragment="SWIG_SciInt32_AsUnsignedLong") {
#define SWIG_AsVal_unsigned_long(scilabValue, valuePointer) SWIG_SciInt32_AsUnsignedLong(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt32_AsUnsignedLong", "header", fragment="SWIG_SciUint32_AsUnsignedInt") {
SWIGINTERN int
SWIG_SciUInt32_AsUnsignedLong(void *_pvApiCtx, SwigSciObject _iVar, unsigned long *_pulValue, char *_fname) {
  unsigned int uiValue = 0.0;
  if(SWIG_SciUint32_AsUnsignedInt(_pvApiCtx, _iVar, &uiValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pulValue = (unsigned long) uiValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned long), "header", fragment="SWIG_SciUint32_FromUnsignedLong") {
#define SWIG_From_unsigned_SS_long(scilabValue) SWIG_SciUint32_FromUnsignedLong(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciUint32_FromUnsignedLong", "header", fragment="SWIG_SciUint32_FromUnsignedInt") {
SWIGINTERN int
SWIG_SciUint32_FromUnsignedLong(void *_pvApiCtx, int _iVarOut, unsigned long _ulValue, char *_fname) {
  return SWIG_SciUint32_FromUnsignedInt(_pvApiCtx, _iVarOut, (unsigned int) _ulValue, _fname);
}
}
