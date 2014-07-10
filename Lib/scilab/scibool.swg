/*
 * C-type: bool
 * Scilab type: boolean scalar
 */
%fragment(SWIG_AsVal_frag(bool), "header") {
SWIGINTERN int
SWIG_AsVal_dec(bool)(SwigSciObject iVar, bool *pbValue) {
  SciErr sciErr;
  int iRet = 0;
  int *piAddrVar = NULL;
  int iTempValue = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (!isBooleanType(pvApiCtx, piAddrVar)) {
      Scierror(999, _("%s: Wrong type for input argument #%d: A boolean expected.\n"), SWIG_Scilab_GetFname(), iVar);
    return SWIG_ERROR;
  }

  if (!isScalar(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A boolean expected.\n"), SWIG_Scilab_GetFname(), iVar);
    return SWIG_ERROR;
  }

  iRet = getScalarBoolean(pvApiCtx, piAddrVar, &iTempValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  *pbValue = iTempValue;

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
 * Scilab type: boolean matrix
 */
%fragment("SWIG_SciBoolean_AsBoolArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_AsBoolArrayAndSize(void *_pvApiCtx, int iVar, int *iRows, int *iCols, bool **pbValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int *piValue = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isBooleanType(_pvApiCtx, piAddrVar)) {
    int i;
    sciErr = getMatrixOfBoolean(_pvApiCtx, piAddrVar, iRows, iCols, &piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }

    *pbValue = (bool*) malloc((*iRows) * (*iCols) * sizeof(bool));
    for (i = 0; i < (*iRows) * (*iCols); i++)
      (*pbValue)[i] = piValue[i] != 0;
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean matrix expected.\n"), fname, iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment("SWIG_SciBoolean_FromBoolArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_FromBoolArrayAndSize(void *_pvApiCtx, int iVarOut, int iRows, int iCols, bool *pbValue) {
  SciErr sciErr;
  int *piValue = NULL;
  int i;

  piValue = (int*) malloc(iRows * iCols * sizeof(int));
  for (i = 0; i < iRows * iCols; i++)
    piValue[i] = pbValue[i];

  sciErr = createMatrixOfBoolean(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + iVarOut, iRows, iCols, piValue);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    free(piValue);
    return SWIG_ERROR;
  }

  free(piValue);
  return SWIG_OK;
}
}

/*
 * C-type: int[]
 * Scilab type: boolean matrix
 */
%fragment("SWIG_SciBoolean_AsIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_AsIntArrayAndSize(void *_pvApiCtx, int iVar, int *iRows, int *iCols, int **piValue, char *fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isBooleanType(_pvApiCtx, piAddrVar)) {
    int i;
    sciErr = getMatrixOfBoolean(_pvApiCtx, piAddrVar, iRows, iCols, piValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean matrix expected.\n"), fname, iVar);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment("SWIG_SciBoolean_FromIntArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciBoolean_FromIntArrayAndSize(void *_pvApiCtx, int iVarOut, int iRows, int iCols, int *piValue) {
  SciErr sciErr;

  sciErr = createMatrixOfBoolean(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + iVarOut, iRows, iCols, piValue);
  if(sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
