/*
 * FLOAT SCALAR
 */

%fragment(SWIG_AsVal_frag(float), "header", fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
SWIG_AsVal_dec(float)(SwigSciObject _iVar, float *_pfValue) {
  double dblValue = 0.0;
  if(SWIG_AsVal_dec(double)(_iVar, &dblValue) != SWIG_OK) {
    return SWIG_ERROR;
  }
  *_pfValue = (float) dblValue;
  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(float), "header") {
SWIGINTERN int
SWIG_From_dec(float)(float _flValue) {
  if (createScalarDouble(pvApiCtx, SWIG_NbInputArgument(pvApiCtx)
    + SWIG_Scilab_GetOutputPosition(), (double)_flValue))
    return SWIG_ERROR;
  return SWIG_OK;
}
}

%fragment("SWIG_SciDouble_AsFloatArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_AsFloatArrayAndSize(void *_pvApiCtx, int _iVar, int *_iRows, int *_iCols, float **_pfValue, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  double *pdValue = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(_pvApiCtx, piAddrVar) && !isVarComplex(_pvApiCtx, piAddrVar)) {
    int i;

    sciErr = getMatrixOfDouble(_pvApiCtx, piAddrVar, _iRows, _iCols, &pdValue);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }

    *_pfValue = (float *) malloc((*_iRows) * (*_iCols) * sizeof(float));
    for (i=0; i < (*_iRows) * (*_iCols); i++)
      (*_pfValue)[i] = (float) pdValue[i];

    return SWIG_OK;
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: A real matrix expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }
}
}

%fragment("SWIG_SciDouble_FromFloatArrayAndSize", "header") {
SWIGINTERN int
SWIG_SciDouble_FromFloatArrayAndSize(void *_pvApiCtx, int _iVarOut, int _iRows, int _iCols, float *_pfValue) {
  SciErr sciErr;
  double *pdValue;
  int i;

  pdValue = (double *) malloc(_iRows * _iCols * sizeof(double));
  for (i = 0; i < _iRows * _iCols; i++)
    pdValue[i] = _pfValue[i];

  sciErr = createMatrixOfDouble(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, _iRows, _iCols, pdValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  free(pdValue);
  return SWIG_OK;
}
}
