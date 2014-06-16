/*
 * C-type: unsigned char
  * Scilab type: double or uint8 scalar
 */
%fragment(SWIG_AsVal_frag(unsigned char), "header", fragment="SWIG_SciUint8_AsUnsignedChar", fragment="<limits.h>") {
#define SWIG_AsVal_unsigned_SS_char(scilabValue, valuePointer) SWIG_SciUint8_AsUnsignedChar(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SWIG_SciUint8_AsUnsignedChar", "header") {
SWIGINTERN int
SWIG_SciUint8_AsUnsignedChar(void *_pvApiCtx, int _iVar, unsigned char *_pucValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  unsigned char *pucData = NULL;

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
    if (_pucValue) {
      sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      if (iPrec != SCI_UINT8) {
        Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), _fname, _iVar);
        return SWIG_ERROR;
      }

      sciErr = getMatrixOfUnsignedInteger8(_pvApiCtx, piAddrVar, &iRows, &iCols, &pucData);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      if (iRows * iCols != 1) {
        Scierror(999, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), _fname, _iVar);
        return SWIG_ERROR;
      }
      *_pucValue = *pucData;
    }
  }
  else if (iType == sci_matrix) {
    if (_pucValue) {
      double *pdData = NULL;
      double dValue = 0.0f;
      sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      if (iRows * iCols != 1) {
        Scierror(999, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), _fname, _iVar);
        return SWIG_TypeError;
      }
      dValue = *pdData;
      if (dValue != floor(dValue)) {
        Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), _fname, _iVar);
        return SWIG_ValueError;
      }
      if ((dValue < 0) || (dValue > UCHAR_MAX)) {
        Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), _fname, _iVar);
        return SWIG_OverflowError;
      }
      *_pucValue = (unsigned char) dValue;
    }
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned char), "header", fragment="SWIG_SciUint8_FromUnsignedChar") {
#define SWIG_From_unsigned_SS_char(value) SWIG_SciUint8_FromUnsignedChar(pvApiCtx, SWIG_Scilab_GetOutputPosition(), value)
}
%fragment("SWIG_SciUint8_FromUnsignedChar", "header") {
SWIGINTERN int
SWIG_SciUint8_FromUnsignedChar(void *_pvApiCtx, int _iVarOut, unsigned char _ucValue) {
  if (createScalarDouble(pvApiCtx,
    SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, (double) _ucValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

/*
 * C-type: unsigned char[]
  * Scilab type: uint8 vector
 */
%fragment("SWIG_SciUint8_AsUnsignedCharArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint8_AsUnsignedCharArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, unsigned char **_pucValue, char *_fname) {
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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_UINT8) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfUnsignedInteger8(_pvApiCtx, piAddrVar, _iRows, _iCols, _pucValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciUint8_FromUnsignedCharArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint8_FromUnsignedCharArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, const unsigned char *_puscValue) {
  SciErr sciErr;

  sciErr = createMatrixOfUnsignedInteger8(pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, _puscValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
