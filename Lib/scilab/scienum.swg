/*
 * C-type: enum
 * Scilab type: int32
 */

%fragment("SWIG_SciInt32_AsEnum", "header", fragment="SWIG_SciInt32_AsInt") {
SWIGINTERN int
SWIG_SciInt32_AsEnum(void *_pvApiCtx, int _iVar, int *_enumValue, char *_fname)
{
  int iValue = 0;
  if (SWIG_SciInt32_AsInt(_pvApiCtx, _iVar, &iValue, _fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
  if (_enumValue)
  {
    *_enumValue = iValue;
  }
  return SWIG_OK;
}
}

%fragment("SWIG_SciInt32_FromEnum", "header", fragment="SWIG_SciInt32_FromInt") {
SWIGINTERN int
SWIG_SciInt32_FromEnum(void *_pvApiCtx, int _iVarOut, int _enumValue, char *_fname)
{
  return SWIG_SciInt32_FromInt(_pvApiCtx, _iVarOut, _enumValue, _fname);
}
}
