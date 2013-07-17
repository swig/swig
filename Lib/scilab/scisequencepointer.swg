/*
 *
 * Scilab list of pointer <-> C++ pointer container
 *
 */

%include <scilist.swg>

%fragment(SWIG_AsCheck_Sequence_frag(ptr), "header",
  fragment="SWIG_ScilabList") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(ptr)(SciObject _obj) {
  return SWIG_CheckScilabList(_obj);
}
}

%fragment(SWIG_AsGet_Sequence_frag(ptr), "header",
  fragment="SWIG_ScilabList") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(ptr)(SciObject _obj, int **_piSequence) {
  return SWIG_GetScilabList(_obj, _piSequence);
}
}

%fragment(SWIG_AsSize_Sequence_frag(ptr), "header",
  fragment="SWIG_ScilabList") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(ptr)(SciObject _obj, int *_piSize) {
  return SWIG_GetScilabListSize(_obj, _piSize);
}
}

%fragment(SWIG_FromCreate_Sequence_frag(ptr), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(ptr)(int _size, int ***_sequence) {
  *_sequence = new int*[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(ptr), "header") {

SWIGINTERN SciObject
SWIG_FromSet_Sequence_dec(ptr)(int _size, int **_sequence) {
  SciErr sciErr;
  int *piListAddr;

  int iVarOut = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();

  sciErr = createList(pvApiCtx, iVarOut, _size, &piListAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  for (int i=0; i<_size; i++)
  {
    sciErr = createPointerInList(pvApiCtx, iVarOut, piListAddr, i + 1, (void *)_sequence[i]);
    if (sciErr.iErr)
    {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
  }
  delete (int*)_sequence;
  return iVarOut;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(ptr), "header") {

SWIGINTERN int
SWIG_AsVal_SequenceItem_dec(ptr)(SciObject _obj, int* _piSequence, int _itemIndex, int **_pItemValue)
{
  SciErr sciErr;
  int *piItemAddr;
  int iType;

  sciErr = getListItemAddress(pvApiCtx, _piSequence, _itemIndex + 1, &piItemAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piItemAddr, &iType);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (iType != sci_pointer)
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A pointer is expected at list item #%d.\n"), fname, _obj, _itemIndex + 1);
    return SWIG_ERROR;
  }

  sciErr = getPointerInList(pvApiCtx, _piSequence, _itemIndex + 1, (void **)_pItemValue);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}

%fragment(SWIG_From_SequenceItem_frag(ptr), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(ptr)(int **_pSequence, int _iItemIndex, int *_itemValue) {
  _pSequence[_iItemIndex] = _itemValue;
}
}
