/*
 *
 * Scilab matrix of int <-> C++ int container
 *
 */

%include <sciint.swg>

%fragment(SWIG_AsCheck_Sequence_frag(int), "header",
  fragment="SWIG_SciInt32_AsIntArrayAndSize") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(int)(SwigSciObject _obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isIntegerType(pvApiCtx, piAddrVar))
  {
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: An integer is expected.\n"), SWIG_Scilab_GetFname(), _obj);
    return SWIG_ERROR;
  }
}
}

%fragment(SWIG_AsGet_Sequence_frag(int), "header",
  fragment="SWIG_SciInt32_AsIntArrayAndSize") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(int)(SwigSciObject _obj, int **_pSequence) {
  int iMatrixRowCount;
  int iMatrixColCount;
  return (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, _pSequence, SWIG_Scilab_GetFname()));
}
}

%fragment(SWIG_AsSize_Sequence_frag(int), "header",
  fragment="SWIG_SciInt32_AsIntArrayAndSize") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(int)(SwigSciObject _obj, int *_piSize) {
  int *piMatrix;
  int iMatrixRowCount;
  int iMatrixColCount;
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, _obj, &iMatrixRowCount, &iMatrixColCount, &piMatrix, SWIG_Scilab_GetFname()) == SWIG_OK) {
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

%fragment(SWIG_FromCreate_Sequence_frag(int), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(int)(int _size, int **_sequence) {
  *_sequence = new int[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(int), "header",
  fragment="SWIG_SciInt32_FromIntArrayAndSize") {

SWIGINTERN SwigSciObject
SWIG_FromSet_Sequence_dec(int)(int _size, int *_sequence) {
  SwigSciObject obj = SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, _size, _sequence);
  delete (int *)_sequence;
  return obj;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(int), "header") {

SWIGINTERN int
SWIG_AsVal_SequenceItem_dec(int)(SwigSciObject _obj, int *_pSequence, int _iItemIndex, int *_pItemValue) {
  *_pItemValue = _pSequence[_iItemIndex];
  return SWIG_OK;
}
}

%fragment(SWIG_From_SequenceItem_frag(int), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(int)(int *_pSequence, int _iItemIndex, int _itemValue) {
  _pSequence[_iItemIndex] = _itemValue;
  return SWIG_OK;
}
}
