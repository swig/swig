/*
 *
 * Scilab matrix of float <-> C++ float container
 *
 */

%include <scifloat.swg>

%fragment(SWIG_AsCheck_Sequence_frag(float), "header") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(float)(SwigSciObject _obj) {
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

%fragment(SWIG_AsGet_Sequence_frag(float), "header",
  fragment="SWIG_SciDouble_AsFloatArrayAndSize") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(float)(SwigSciObject _obj, float **_pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;

  return (SWIG_SciDouble_AsFloatArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, _pSequence, SWIG_Scilab_GetFname()));
}
}

%fragment(SWIG_AsSize_Sequence_frag(float), "header",
  fragment="SWIG_SciDouble_AsFloatArrayAndSize") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(float)(SwigSciObject _obj, int *_piSize) {
  float *pdblMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (SWIG_SciDouble_AsFloatArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, &pdblMatrix, SWIG_Scilab_GetFname()) == SWIG_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(999, _("%s: Wrong size for input argument #%d: A float vector is expected.\n"), SWIG_Scilab_GetFname(), _obj);
      return SWIG_ERROR;
    }
    *_piSize = iMatrixRowCount * iMatrixColCount;
    return SWIG_OK;
  }
  return SWIG_ERROR;
}
}

%fragment(SWIG_FromCreate_Sequence_frag(float), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(float)(int _size, float **_sequence) {
  *_sequence = new float[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(float), "header",
  fragment="SWIG_SciDouble_FromFloatArrayAndSize") {

SWIGINTERN SwigSciObject
SWIG_FromSet_Sequence_dec(float)(int _size, float *_sequence) {
  SwigSciObject obj = SWIG_SciDouble_FromFloatArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, _size, _sequence);
  delete (float *)_sequence;
  return obj;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(float), "header") {

SWIGINTERN float
SWIG_AsVal_SequenceItem_dec(float)(SwigSciObject _obj, float *_pSequence, int _iItemIndex) {
  return _pSequence[_iItemIndex];
}
}

%fragment(SWIG_From_SequenceItem_frag(float), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(float)(float *_pSequence, int _iItemIndex, float _itemValue) {
  _pSequence[_iItemIndex] = _itemValue;
  return SWIG_OK;
}
}

