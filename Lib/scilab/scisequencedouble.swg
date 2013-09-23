/*
 *
 * Scilab matrix of double <-> C++ double container
 *
 */

%include <scidouble.swg>

%fragment(SWIG_AsCheck_Sequence_frag(double), "header",
  fragment="SWIG_SciDouble_AsDoubleArrayAndSize") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(double)(SwigSciObject _obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isDoubleType(pvApiCtx, piAddrVar))
  {
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A double is expected.\n"), SWIG_Scilab_GetFname(), _obj);
    return SWIG_ERROR;
  }
}
}

%fragment(SWIG_AsGet_Sequence_frag(double), "header",
  fragment="SWIG_SciDouble_AsDoubleArrayAndSize") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(double)(SwigSciObject _obj, double **_pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, _pSequence, SWIG_Scilab_GetFname()));
}
}

%fragment(SWIG_AsSize_Sequence_frag(double), "header",
  fragment="SWIG_SciDouble_AsDoubleArrayAndSize") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(double)(SwigSciObject _obj, int *_piSize) {
  double *pdblMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, &pdblMatrix, SWIG_Scilab_GetFname()) == SWIG_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A double vector is expected.\n"), SWIG_Scilab_GetFname(), _obj);
      return SWIG_ERROR;
    }
    *_piSize = iMatrixRowCount * iMatrixColCount;
    return SWIG_OK;
  }
  return SWIG_ERROR;
}
}

%fragment(SWIG_FromCreate_Sequence_frag(double), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(double)(int _size, double **_sequence) {
  *_sequence = new double[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(double), "header",
  fragment="SWIG_SciDouble_FromDoubleArrayAndSize") {

SWIGINTERN SwigSciObject
SWIG_FromSet_Sequence_dec(double)(int _size, double *_sequence) {
  SwigSciObject obj = SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, _size, _sequence);
  delete (double *)_sequence;
  return obj;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(double), "header") {

SWIGINTERN int
SWIG_AsVal_SequenceItem_dec(double)(SwigSciObject _obj, double *_pSequence, int _iItemIndex, double *_pItemValue) {
  *_pItemValue = _pSequence[_iItemIndex];
  return SWIG_OK;
}
}

%fragment(SWIG_From_SequenceItem_frag(double), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(double)(double *_pSequence, int _iItemIndex, double _itemValue) {
  _pSequence[_iItemIndex] = _itemValue;
  return SWIG_OK;
}
}

