/*
 * C-type: int
 * Scilab type: double or int32
 */

%fragment(SWIG_AsVal_frag(int), "header", fragment="SWIG_SciDoubleOrInt32_AsInt", fragment="<limits.h>") {
%#define SWIG_AsVal_int(scilabValue, valuePointer) SWIG_SciDoubleOrInt32_AsInt(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDoubleOrInt32_AsInt", "header") {
SWIGINTERN int
SWIG_SciDoubleOrInt32_AsInt(void *_pvApiCtx, SwigSciObject _iVar, int *_piValue, char *_fname)
{
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
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
    int iPrec = 0;
    int *piData = NULL;

    sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iPrec != SCI_INT32) {
      Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    sciErr = getMatrixOfInteger32(_pvApiCtx, piAddrVar, &iRows, &iCols, &piData);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iRows * iCols != 1) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    *_piValue = *piData;
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
      Scierror(999, _("%s: Wrong size for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
      return SWIG_TypeError;
    }
    dValue = *pdData;
    if (dValue != floor(dValue)) {
      Scierror(999, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), _fname, _iVar);
      return SWIG_ValueError;
    }
    if ((dValue < INT_MIN) || (dValue > INT_MAX)) {
      Scierror(999, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 32-bit signed integer.\n"), _fname, _iVar);
      return SWIG_OverflowError;
    }
    *_piValue = (int) dValue;
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer or a double expected.\n"), _fname, _iVar);
    return SWIG_TypeError;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(int), "header", fragment="SWIG_SciDouble_FromInt") {
%#define SWIG_From_int(scilabValue) SWIG_SciDouble_FromInt(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_FromInt", "header") {
SWIGINTERN int
SWIG_SciDouble_FromInt(void *_pvApiCtx, int _iVarOut, int _iValue, char *_fname){
  if (createScalarDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx)
    + _iVarOut, (double) _iValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

/*
 * C-type: int
 * Scilab type: 32-bit signed integer matrix
 */
%fragment("SWIG_SciInt32_AsIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt32_AsIntArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, int **_piValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iPrec = 0;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  // Accepts 32-bit signed integer matrix for input
  if (isIntegerType(_pvApiCtx, piAddrVar))
  {
    sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr)
    {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if (iPrec != SCI_INT32)
    {
      Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer matrix expected.\n"), _fname, _iVar);
      return SWIG_ERROR;
    }
    sciErr = getMatrixOfInteger32(_pvApiCtx, piAddrVar, _iRows, _iCols, _piValue);
    if (sciErr.iErr)
    {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    return SWIG_OK;
  }
  else if (isDoubleType(_pvApiCtx, piAddrVar))
  {
    double **dblValue;

    // Check if input matrix is not empty (empty matrix type is double)
    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, _iRows, _iCols, dblValue);
    if (sciErr.iErr)
    {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    if ((*_iRows > 0) || (*_iCols > 0))
    {
      Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer matrix expected.\n"), _fname, _iVar);
      return SWIG_ERROR;
    }
    *_piValue = (int*) malloc(sizeof(int*));
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A 32-bit signed integer matrix expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}

%fragment("SWIG_SciInt32_FromIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciInt32_FromIntArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, const int *_piData) {
  SciErr sciErr;

  sciErr = createMatrixOfInteger32(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, _piData);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_CreateScilabVariable_frag(int), "wrapper") {
SWIGINTERN int
SWIG_CreateScilabVariable_dec(int)(void *_pvApiCtx, const char* _psVariableName, const int _iVariableValue) {
  SciErr sciErr;
  sciErr = createNamedMatrixOfInteger32(_pvApiCtx, _psVariableName, 1, 1, &_iVariableValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}
