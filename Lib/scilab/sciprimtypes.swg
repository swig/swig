%include <scidouble.swg>
%include <scilong.swg>
%include <scifloat.swg>

%include <scilonglong.swg>

%include <sciint.swg>
%include <sciunsignedint.swg>

%include <scishort.swg>
%include <sciunsignedshort.swg>

%include <scichar.swg>
%include <scisignedchar.swg>
%include <sciunsignedchar.swg>

%include <scipointer.swg>
%include <scibool.swg>

%fragment("SwigScilabInt32ToEnum", "header", fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
SwigScilabInt32ToEnum(void *_pvApiCtx, int _iVar, int *_enumValue, char* _fname)
{
  int iValue = 0;
  if (SWIG_AsVal_dec(int)(_iVar, &iValue) != SWIG_OK)
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
%fragment("SwigScilabInt32FromEnum", "header") {
SWIGINTERN int
SwigScilabInt32FromEnum(void *_pvApiCtx, int _iVarOut, int _enumValue)
{
  int iRet;
  iRet = createScalarInteger32(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + _iVarOut, _enumValue);
  if (iRet)
  {
    return SWIG_ERROR;
  }
  SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + _iVarOut);
  return SWIG_OK;
}
}
