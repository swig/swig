/*
 * C-type: short
 * Scilab type: double scalar
 */

%fragment(SWIG_AsVal_frag(short), "header", fragment="SWIG_SciInt16_AsShort") {
#define SWIG_AsVal_short(scilabValue, valuePointer) SWIG_SciInt16_AsShort(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt16_AsShort", "header") {
SWIGINTERN int
SWIG_SciInt16_AsShort(void *_pvApiCtx, int _iVar, short *_psValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;
  short *psData = NULL;

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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit signed integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT16) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit signed integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger16(_pvApiCtx, piAddrVar, &iRows, &iCols, &psData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A 16-bit signed integer expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  *_psValue = *psData;

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(short), "header", fragment="SWIG_SciInt16_FromShort") {
#define SWIG_From_short(scilabValue) SWIG_SciInt16_FromShort(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciInt16_FromShort", "header") {
SWIGINTERN int
SWIG_SciInt16_FromShort(void *_pvApiCtx, int _iVarOut, signed short _usValue, char *_fname) {
  SciErr sciErr;
  int iRowsOut = 1;
  int iColsOut = 1;
  sciErr = createMatrixOfInteger16(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, iRowsOut, iColsOut, &_usValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}

/*
 * C-type: short[]
 * Scilab type: int16 vector
 * See in scitypemaps.swg
 */
/*
 * C-type: short[ANY]
 * Scilab type: int16 vector
 */
%fragment("SWIG_SciInt16_AsShortArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt16_AsShortArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, short **_psValue, char *_fname) {
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
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit signed integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iPrec != SCI_INT16) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 16-bit signed integer vector expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfInteger16(_pvApiCtx, piAddrVar, _iRows, _iCols, _psValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment("SWIG_SciInt16_FromShortArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt16_FromShortArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, short *_psValue) {
  SciErr sciErr;
  sciErr = createMatrixOfInteger16(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, _psValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}

