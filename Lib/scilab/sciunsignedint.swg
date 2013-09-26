/*
 * C-type: unsigned int
 * Scilab type: uint32 scalar
 */
%fragment(SWIG_AsVal_frag(unsigned int), "header", fragment="SWIG_SciUint32_AsUnsignedInt") {
#define SWIG_AsVal_unsigned_SS_int(scilabValue, valuePointer) SWIG_SciUint32_AsUnsignedInt(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SWIG_SciUint32_AsUnsignedInt", "header") {
SWIGINTERN int
SWIG_SciUint32_AsUnsignedInt(void *_pvApiCtx, int _iVar, unsigned int *_puiValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  unsigned int *puiData = NULL;

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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_UINT32) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfUnsignedInteger32(_pvApiCtx, piAddrVar, &iRows, &iCols, &puiData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit unsigned integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  *_puiValue = *puiData;

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned int), "header", fragment="SWIG_SciUint32_FromUnsignedInt") {
#define SWIG_From_unsigned_SS_int(scilabValue) SWIG_SciUint32_FromUnsignedInt(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue)
}
%fragment("SWIG_SciUint32_FromUnsignedInt", "header") {
SWIGINTERN int
SWIG_SciUint32_FromUnsignedInt(void *_pvApiCtx, int _iVarOut, unsigned int _uiValue) {
  SciErr sciErr;
  int iRowsOut = 1;
  int iColsOut = 1;

  sciErr = createMatrixOfUnsignedInteger32(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, iRowsOut, iColsOut, &_uiValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}

/*
 * C-type: unsigned int[]
 * Scilab type: uint32 vector
 */
%fragment("SWIG_SciUint32_AsUnsignedIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint32_AsUnsignedIntArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, unsigned int **_puiValue, char *_fname) {
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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_UINT32) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit unsigned integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfUnsignedInteger32(_pvApiCtx, piAddrVar, _iRows, _iCols, _puiValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciUint32_FromUnsignedIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciUint32_FromUnsignedIntArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, unsigned int *_puiValue) {
  SciErr sciErr;

  sciErr = createMatrixOfUnsignedInteger32(_pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + _iVarOut, _iRows, _iCols, _puiValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(pvApiCtx) + _iVarOut;
}
}

