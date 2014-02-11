/*
 * C-type: signed char
 * Scilab type: int8
 */
%fragment(SWIG_AsVal_frag(signed char), "header", fragment="SWIG_SciDoubleOrInt8_AsShort", fragment="<limits.h>") {
#define SWIG_AsVal_signed_SS_char(scilabValue, valuePointer) SWIG_SciDoubleOrInt8_AsShort(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SWIG_SciDoubleOrInt8_AsShort", "header") {
SWIGINTERN int
SWIG_SciDoubleOrInt8_AsShort(void *_pvApiCtx, int _iVar, signed char *_pscValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
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

  if (iType == sci_ints) {
    char *pcData = NULL;

    sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iPrec != SCI_INT8) {
      Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    sciErr = getMatrixOfInteger8(_pvApiCtx, piAddrVar, &iRows, &iCols, &pcData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A 8-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    *_pscValue = *pcData;
  }
  else if (iType == sci_matrix) {
    double *pdData = NULL;
    double dValue = 0.0f;

    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A 8-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    dValue = *pdData;
    if (dValue != floor(dValue)) {
      Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 8-bit signed integer.\n"), _fname, _iVar);
      return SWIG_ValueError;
    }
    if ((dValue < SCHAR_MIN) || (dValue > SCHAR_MAX)) {
      Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 8-bit signed integer.\n"), _fname, _iVar);
      return SWIG_OverflowError;
    }
    *_pscValue = (signed char) dValue;
  }
  else {
     Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit signed integer or a double expected.\n"), _fname, _iVar);
    return SWIG_TypeError;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(signed char), "header", fragment="SWIG_SciDouble_FromSignedChar") {
#define SWIG_From_signed_SS_char(scilabValue) SWIG_SciDouble_FromSignedChar(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue)
}
%fragment("SWIG_SciDouble_FromSignedChar", "header") {
SWIGINTERN int
SWIG_SciDouble_FromSignedChar(void *_pvApiCtx, int _iVarOut, signed char _scValue) {
  if (createScalarDouble(_pvApiCtx,
    SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, (double) _scValue))
    return SWIG_ERROR;
  return SWIG_OK;
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

  return SWIG_OK;
}
}
