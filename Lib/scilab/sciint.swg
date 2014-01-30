/*
 * C-type: int
 * Scilab type: double or 32-bit signed integer
 */

%fragment(SWIG_AsVal_frag(int), "header", fragment="SWIG_SciDoubleOrInt32_AsInt") {
%#define SWIG_AsVal_int(scilabValue, valuePointer) SWIG_SciDoubleOrInt32_AsInt(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDoubleOrInt32_AsInt", "header") {
SWIGINTERN int
SWIG_SciDoubleOrInt32_AsInt(void *_pvApiCtx, SwigSciObject _iVar, int *_piValue, char *_fname)
{
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;
  int iPrecision = 0;
  int iValue;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isScalar(_pvApiCtx, piAddrVar))
  {
    Scierror(999, _("%s: Wrong size for argument %d: a scalar expected.\n"),
      SWIG_Scilab_GetFname(),_iVar);
    return 999;
  }

  // Accepts double or 32-bit signed integer
  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar))
  {
    double dValue = 0.0;
    iRet = getScalarDouble(_pvApiCtx, piAddrVar, &dValue);
    if (iRet)
    {
      return SWIG_ERROR;
    }

    iValue = (int)dValue;
  }
  else if (isIntegerType(pvApiCtx, piAddrVar))
  {
    sciErr = getMatrixOfIntegerPrecision(_pvApiCtx, piAddrVar, &iPrecision);
    if (sciErr.iErr)
    {
      printError(&sciErr, 0);
      return sciErr.iErr;
    }

    if (iPrecision == SCI_INT32)
    {
      iRet = getScalarInteger32(_pvApiCtx, piAddrVar, &iValue);
    }
  }

  if (iRet == 0)
  {
    if (_piValue)
    {
      *_piValue = iValue;
    }
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for argument %d: A 32-bit signed integer or a real expected.\n"),
        SWIG_Scilab_GetFname(), _iVar);
    return 999;
  }
}
}

%fragment(SWIG_From_frag(int), "header", fragment="SWIG_SciDouble_FromInt") {
%#define SWIG_From_int(scilabValue) SWIG_SciDouble_FromInt(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_SciDouble_FromInt", "header") {
SWIGINTERN int
SWIG_SciDouble_FromInt(void *_pvApiCtx, int _iVarOut, int _iValue, char *_fname)
{
  if (createScalarDouble(_pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + _iVarOut, (double) _iValue)) {
    return SWIG_ERROR;
  }

  return SWIG_NbInputArgument(_pvApiCtx) + _iVarOut;
}
}

/*
 * C-type: size_t
 * Scilab type: see int
 */

%fragment(SWIG_AsVal_frag(size_t), "header", fragment="SWIG_Int_AsSize") {
%#define SWIG_AsVal_size_t(scilabValue, valuePointer) SWIG_Int_AsSize(pvApiCtx, scilabValue, valuePointer, SWIG_Scilab_GetFname())
}
%fragment("SWIG_Int_AsSize", "header", fragment=SWIG_AsVal_frag(int))
{
SWIGINTERN int
SWIG_Int_AsSize(void *_pvApiCtx, SwigSciObject _iVar, size_t *_piValue, char *_fname)
{
  int iValue = 0;
  if (SWIG_AsVal_dec(int)(_iVar, &iValue) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
  if (_piValue)
  {
    *_piValue = (size_t) iValue;
  }
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(size_t), "header", fragment="SWIG_Int_FromSize") {
%#define SWIG_From_size_t(scilabValue) SWIG_Int_FromSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), scilabValue, SWIG_Scilab_GetFname())
}
%fragment("SWIG_Int_FromSize", "header", fragment=SWIG_From_frag(int)) {
SWIGINTERN int
SWIG_Int_FromSize(void *_pvApiCtx, int _iVarOut, size_t _iValue, char *_fname)
{
  return SWIG_From_dec(int)((int)_iValue);
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

  sciErr = createMatrixOfInteger32(_pvApiCtx, Rhs + _iVarOut, _iRows, _iCols, _piData);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return Rhs + _iVarOut;
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
