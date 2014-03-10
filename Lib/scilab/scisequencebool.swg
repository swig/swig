/*
 *
 * Scilab matrix of bool <-> C++ bool container
 *
 */

%include <scibool.swg>

%fragment(SWIG_AsCheck_Sequence_frag(bool), "header") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(bool)(SwigSciObject _obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isBooleanType(pvApiCtx, piAddrVar))
  {
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A boolean is expected.\n"), SWIG_Scilab_GetFname(), _obj);
    return SWIG_ERROR;
  }
}
}

%fragment(SWIG_AsGet_Sequence_frag(bool), "header",
  fragment="SWIG_SciBoolean_AsIntArrayAndSize") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(bool)(SwigSciObject _obj, int **_pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (SWIG_SciBoolean_AsIntArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, _pSequence, SWIG_Scilab_GetFname()));
}
}

%fragment(SWIG_AsSize_Sequence_frag(bool), "header",
  fragment="SWIG_SciBoolean_AsIntArrayAndSize") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(bool)(SwigSciObject _obj, int *_piSize) {
  int *piMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (SWIG_SciBoolean_AsIntArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, &piMatrix, SWIG_Scilab_GetFname()) == SWIG_OK) {
    if ((iMatrixRowCount > 1) && (iMatrixColCount > 1)) {
      Scierror(999, _("%s: Wrong size for input argument #%d: An integer vector is expected.\n"), SWIG_Scilab_GetFname(), _obj);
      return SWIG_ERROR;
    }
    *_piSize = iMatrixRowCount * iMatrixColCount;
    return SWIG_OK;
  }
  return SWIG_ERROR;
}
}

%fragment(SWIG_FromCreate_Sequence_frag(bool), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(bool)(int _size, int **_sequence) {
  *_sequence = new int[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(bool), "header",
  fragment="SWIG_SciBoolean_FromIntArrayAndSize") {

SWIGINTERN SwigSciObject
SWIG_FromSet_Sequence_dec(bool)(int _size, int *_sequence) {
  SwigSciObject obj = SWIG_SciBoolean_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, _size, _sequence);
  delete (int *)_sequence;
  return obj;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(bool), "header") {

SWIGINTERN bool
SWIG_AsVal_SequenceItem_dec(bool)(SwigSciObject _obj, int *_pSequence, int _iItemIndex) {
  return _pSequence[_iItemIndex];
}
}

%fragment(SWIG_From_SequenceItem_frag(bool), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(bool)(int *_pSequence, int _iItemIndex, bool _itemValue) {
  _pSequence[_iItemIndex] = _itemValue;
  return SWIG_OK;
}
}
