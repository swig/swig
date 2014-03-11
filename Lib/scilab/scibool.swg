/*
 * C-type: bool
 * Scilab type: boolean scalar
 */
%fragment(SWIG_AsVal_frag(bool), "header") {
SWIGINTERN int
SWIG_AsVal_dec(bool)(SwigSciObject _iVar, bool *_pbValue) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;
  int iTempValue = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isBooleanType(pvApiCtx, piAddrVar)) {
      Scierror(999, _("%s: Wrong type for input argument #%d: A boolean expected.\n"), SWIG_Scilab_GetFname(), _iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A boolean expected.\n"), SWIG_Scilab_GetFname(), _iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarBoolean(pvApiCtx, piAddrVar, &iTempValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  *_pbValue = iTempValue;

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(bool), "header") {
SWIGINTERN int
SWIG_From_dec(bool)(bool _bValue) {
  if (createScalarBoolean(pvApiCtx, SWIG_NbInputArgument(pvApiCtx)
    + SWIG_Scilab_GetOutputPosition(), _bValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

/*
 * C-type: bool[]
 * Scilab type: boolean vector (but converted to int first because can not cast bool** to int **
 */
%fragment("SWIG_SciBoolean_AsBoolArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_AsBoolArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, bool **_pbValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int *piValue = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isBooleanType(_pvApiCtx, piAddrVar)) {
    int i;
    sciErr = getMatrixOfBoolean(_pvApiCtx, piAddrVar, _iRows, _iCols, &piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }

    *_pbValue = (bool*) malloc((*_iRows) * (*_iCols) * sizeof(bool));
    for (i=0; i< (*_iRows) * (*_iCols); i++)
      (*_pbValue)[i] = piValue[i] != 0;
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean matrix expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment("SWIG_SciBoolean_FromBoolArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_FromBoolArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, bool *_pbValue) {
  SciErr sciErr;
  int *piValue = NULL;
  int i;

  piValue = (int*) malloc(_iRows * _iCols * sizeof(int));
  for (i=0; i< _iRows * _iCols; i++)
    piValue[i] = _pbValue[i];

  sciErr = createMatrixOfBoolean(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, piValue);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    free(piValue);
    return SWIG_ERROR;
  }

  free(piValue);
  return SWIG_OK;
}
}
