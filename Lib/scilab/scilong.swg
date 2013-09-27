/*
 * C-type: long
 * Scilab type: int32
 */

%fragment(SWIG_AsVal_frag(long), "header", fragment="SWIG_SciInt32_AsLong") {
#define SWIG_AsVal_long(scilabValue, valuePointer) SWIG_SciInt32_AsLong(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname());
}
%fragment("SWIG_SciInt32_AsLong", "header", fragment="SWIG_SciInt32_AsInt") {
SWIGINTERN int
SWIG_SciInt32_AsLong(void *_pvApiCtx, SwigSciObject _iVar, long *_plValue, char *_fname) {
  int iValue = 0.0;
  if(SWIG_SciInt32_AsInt(_pvApiCtx, _iVar, &iValue, _fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_plValue = (long) iValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(long), "header", fragment="SWIG_SciInt32_FromLong") {
#define SWIG_From_long(scilabValue) SWIG_SciInt32_FromLong(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt32_FromLong", "header", fragment="SWIG_SciInt32_FromInt") {
SWIGINTERN int
SWIG_SciInt32_FromLong(void *_pvApiCtx, int _iVarOut, long _lValue, char *_fname) {
  return SWIG_SciInt32_FromInt(_pvApiCtx, _iVarOut, (int)_lValue, _fname);
}
}

/*
 * C-type: ptrdiff_t
 * Scilab type: int32
 */

%fragment(SWIG_AsVal_frag(ptrdiff_t), "header", fragment="SWIG_SciInt32_AsPtrDiff") {
#define SWIG_AsVal_ptrdiff_t(scilabValue, valuePointer) SWIG_SciInt32_AsPtrDiff(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt32_AsPtrDiff", "header", fragment="SWIG_SciInt32_AsInt")
{
SWIGINTERN int
SWIG_SciInt32_AsPtrDiff(void *_pvApiCtx, SwigSciObject _iVar, ptrdiff_t *_piValue, char *_fname)
{
  int iValue = 0;
  if (SWIG_SciInt32_AsInt(_pvApiCtx, _iVar, &iValue, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
  if (_piValue)
  {
    *_piValue = (ptrdiff_t) iValue;
  }
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(ptrdiff_t), "header", fragment="SWIG_SciInt32_FromPtrDiff") {
#define SWIG_From_ptrdiff_t(scilabValue) SWIG_SciInt32_FromPtrDiff(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt32_FromPtrDiff", "header", fragment="SWIG_SciInt32_FromInt") {
SWIGINTERN int
SWIG_SciInt32_FromPtrDiff(void *_pvApiCtx, int _iVarOut, ptrdiff_t _iValue, char *_fname)
{
  return SWIG_SciInt32_FromInt(_pvApiCtx, _iVarOut, (int)_iValue, _fname);
}
}
