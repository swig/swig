/*
 * C-type: enum
 * Scilab type: double or int32
 */

%fragment(SWIG_AsVal_frag(Enum), "header", fragment="SWIG_Int_AsEnum") {
%#define SWIG_AsVal_Enum(scilabValue, valuePointer) SWIG_Int_AsEnum(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_Int_AsEnum", "header", fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
SWIG_Int_AsEnum(void *_pvApiCtx, int _iVar, int *_enumValue, char *_fname) {
  int iValue = 0;
  if (SWIG_AsVal_dec(int)(_iVar, &iValue) != SWIG_OK)
    return SWIG_ERROR;
  *_enumValue = iValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(Enum), "header", fragment="SWIG_Int_FromEnum") {
%#define SWIG_From_Enum(scilabValue) SWIG_Int_FromEnum(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_Int_FromEnum", "header", fragment=SWIG_From_frag(int)) {
SWIGINTERN int
SWIG_Int_FromEnum(void *_pvApiCtx, int _iVarOut, int _enumValue, char *_fname) {
  return SWIG_From_dec(int)(_enumValue);
}
}
