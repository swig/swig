/*
 * C-type: short
 * Scilab type: double scalar
 */
%fragment(SWIG_AsVal_frag(short), "header", fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
SWIG_AsVal_dec(short)(SwigSciObject _iVar, short *_pshValue) {
  int iValue = 0.0;
  if(SWIG_AsVal_dec(int)(_iVar, &iValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pshValue = (short) iValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(short), "header", fragment=SWIG_From_frag(int)) {
SWIGINTERN int
SWIG_From_dec(short)(short _shValue) {
  int iValue = (int) _shValue;
  return SWIG_From_dec(int)(iValue);
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

  sciErr = createMatrixOfInteger16(_pvApiCtx, Rhs + _iVarOut, _iRows, _iCols, _psValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
}
}

