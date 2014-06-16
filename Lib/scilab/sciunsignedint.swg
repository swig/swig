/*
 * C-type: unsigned int
 * Scilab type: double or uint32 scalar
 */
%fragment(SWIG_AsVal_frag(unsigned int), "header", fragment="SWIG_SciUint32_AsUnsignedInt", fragment="<limits.h>") {
%#define SWIG_AsVal_unsigned_SS_int(scilabValue, valuePointer) SWIG_SciUint32_AsUnsignedInt(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
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

  if (iType == sci_ints) {
    if (_puiValue) {
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
    }
  }
  else if (iType == sci_matrix) {
    if (_puiValue) {
      double *pdData = NULL;
      double dValue = 0.0f;
      sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, &iRows, &iCols, &pdData);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      if (iRows * iCols != 1) {
        Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit unsigned integer or a double expected.\n"), _fname, _iVar);
        return SWIG_TypeError;
      }
      dValue = *pdData;
      if (dValue != floor(dValue)) {
        Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 32-bit unsigned integer.\n"), _fname, _iVar);
        return SWIG_ValueError;
      }
      if ((dValue < 0) || (dValue > UINT_MAX)) {
        Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 32-bit unsigned integer.\n"), _fname, _iVar);
        return SWIG_OverflowError;
      }
      *_puiValue = (unsigned int) dValue;
    }
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit unsigned integer or a double expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(unsigned int), "header", fragment="SWIG_SciUint32_FromUnsignedInt") {
%#define SWIG_From_unsigned_SS_int(scilabValue) SWIG_SciUint32_FromUnsignedInt(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciUint32_FromUnsignedInt", "header") {
SWIGINTERN int
SWIG_SciUint32_FromUnsignedInt(void *_pvApiCtx, int _iVarOut, unsigned int _uiValue, char *_fname) {
  if (createScalarDouble(_pvApiCtx,
    SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, (double) _uiValue))
    return SWIG_ERROR;
  return SWIG_OK;
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

  return SWIG_OK;
}
}

