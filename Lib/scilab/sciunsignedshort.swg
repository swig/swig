/*
 * C-type: unsigned short
 * Scilab type: uint16 scalar
 */
%fragment(SWIG_AsVal_frag(unsigned short), "header", fragment="SWIG_SciUint16_AsUnsignedShort") {
%#define SWIG_AsVal_unsigned_SS_short(scilabValue, valuePointer) SWIG_SciUint16_AsUnsignedShort(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciUint16_AsUnsignedShort", "header") {
SWIGINTERN int
SWIG_SciUint16_AsUnsignedShort(void *_pvApiCtx, int _iVar, unsigned short *_pusValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  unsigned short *pusData = NULL;

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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_UINT16) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfUnsignedInteger16(_pvApiCtx, piAddrVar, &iRows, &iCols, &pusData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A 16-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  *_pusValue = *pusData;

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned short), "header", fragment="SWIG_SciUint16_FromUnsignedShort") {
%#define SWIG_From_unsigned_SS_short(scilabValue) SWIG_SciUint16_FromUnsignedShort(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciUint16_FromUnsignedShort", "header") {
SWIGINTERN int
SWIG_SciUint16_FromUnsignedShort(void *_pvApiCtx, int _iVarOut, unsigned short _usValue, char *_fname) {
  int iVarOut = SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
  if (createScalarUnsignedInteger16(_pvApiCtx, iVarOut, _usValue))
    return SWIG_ERROR;
  return iVarOut;
}
}

/*
 * C-type: unsigned short[]
 * Scilab type: uint16 vector
 */
%fragment("SWIG_SciUint16_AsUnsignedShortArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint16_AsUnsignedShortArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, unsigned short **_pusValue, char *_fname) {
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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_UINT16) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfUnsignedInteger16(_pvApiCtx, piAddrVar, _iRows, _iCols, _pusValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciUint16_FromUnsignedShortArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint16_FromUnsignedShortArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, unsigned short *_pusValue) {
  SciErr sciErr;

  sciErr = createMatrixOfUnsignedInteger16(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, _pusValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}
