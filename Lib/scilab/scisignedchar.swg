/*
 * C-type: signed char
 * Scilab type: int8 scalar
 */
%fragment(SWIG_AsVal_frag(signed char), "header", fragment="SwigScilabInt8ToSignedChar") {
#define SWIG_AsVal_signed_SS_char(scilabValue, valuePointer) SwigScilabInt8ToSignedChar(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SwigScilabInt8ToSignedChar", "header") {
SWIGINTERN int
SwigScilabInt8ToSignedChar(void *_pvApiCtx, int _iVar, signed char *_pscValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  char *pcData = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(_pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_ints) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT8) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger8(_pvApiCtx, piAddrVar, &iRows, &iCols, &pcData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A 8-bit integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  *_pscValue = *pcData;

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(signed char), "header", fragment="SwigScilabInt8FromSignedChar") {
#define SWIG_From_signed_SS_char(value) SwigScilabInt8FromSignedChar(pvApiCtx, $result, value)
}
%fragment("SwigScilabInt8FromSignedChar", "header") {
SWIGINTERN int
SwigScilabInt8FromSignedChar(void *_pvApiCtx, int _iVarOut, signed char _scValue) {
  int iVarOut = SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
  if (createScalarInteger8(pvApiCtx, iVarOut, _scValue))
    return SWIG_ERROR;
  return iVarOut;
}
}

/*
 * C-type: signed char[]
 * Scilab type: int8 vector
 */
%fragment("SWIG_SciInt8_AsSignedCharArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt8_AsSignedCharArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, signed char **_pscValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(_pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_ints) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT8) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger8(_pvApiCtx, piAddrVar, _iRows, _iCols, (char **)_pscValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciInt8_FromSignedCharArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt8_FromSignedCharArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, const signed char *_pscValue) {
  SciErr sciErr;

  sciErr = createMatrixOfInteger8(pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, (const char *)_pscValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}
