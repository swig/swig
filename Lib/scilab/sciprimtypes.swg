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

%fragment("SwigScilabInt32ToEnum", "header") {
SWIGINTERN int
SwigScilabInt32ToEnum(void *_pvApiCtx, int _iVar, int *_enumValue, char* _fname) {
  SciErr sciErr;
  int iPrec = 0;
  int iRows = 1;
  int iCols = 1;
  int *piAddrVar = NULL;
  int *piData = NULL;

  sciErr = getVarAddressFromPosition(pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT32) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, &piData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  *_enumValue = (int)piData[0];

  return SWIG_OK;
}
}
%fragment("SwigScilabInt32FromEnum", "header") {
SWIGINTERN int
SwigScilabInt32FromEnum(void *_pvApiCtx, int _iVarOut, int _enumValue) {
  SciErr sciErr;
  int iRowsOut = 1;
  int iColsOut = 1;

  sciErr = createMatrixOfInteger32(pvApiCtx, Rhs + _iVarOut, iRowsOut, iColsOut, &_enumValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  AssignOutputVariable(pvApiCtx, _iVarOut) = nbInputArgument(pvApiCtx) + _iVarOut;

  return SWIG_OK;

}
}
