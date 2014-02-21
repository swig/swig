/*
 *char
 * Scilab matrix of string <-> C++ std::string container
 *
 */

%include <scichar.swg>

%fragment(SWIG_AsCheck_Sequence_frag(std::string), "header",
  fragment="SWIG_SciString_AsCharPtrArrayAndSize") {

SWIGINTERN int
SWIG_AsCheck_Sequence_dec(std::string)(SwigSciObject _obj) {
  SciErr sciErr;
  int *piAddrVar;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (isStringType(pvApiCtx, piAddrVar))
  {
    return SWIG_OK;
  }
  else
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A string is expected.\n"), SWIG_Scilab_GetFname(), _obj);
    return SWIG_ERROR;
  }
}
}

%fragment(SWIG_AsGet_Sequence_frag(std::string), "header",
  fragment="SWIG_SciString_AsCharPtrArrayAndSize") {

SWIGINTERN int
SWIG_AsGet_Sequence_dec(std::string)(SwigSciObject _obj, char ***_pSequence) {
  int iSize;
  return (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, _obj, _pSequence, &iSize, SWIG_Scilab_GetFname()));
}
}

%fragment(SWIG_AsSize_Sequence_frag(std::string), "header",
  fragment="SWIG_SciString_AsCharPtrArrayAndSize") {

SWIGINTERN int
SWIG_AsSize_Sequence_dec(std::string)(SwigSciObject _obj, int *_piSize) {
  char **pstMatrix;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, _obj, &pstMatrix, _piSize, SWIG_Scilab_GetFname()) == SWIG_OK) {
    return SWIG_OK;
  }
  return SWIG_ERROR;
}
}

%fragment(SWIG_FromCreate_Sequence_frag(std::string), "header") {

SWIGINTERN int
SWIG_FromCreate_Sequence_dec(std::string)(int _size, char ***_sequence) {
  *_sequence = new char*[_size];
  return *_sequence != NULL ? SWIG_OK : SWIG_ERROR;
}
}

%fragment(SWIG_FromSet_Sequence_frag(std::string), "header",
  fragment="SWIG_SciString_FromCharPtrArray") {

SWIGINTERN SwigSciObject
SWIG_FromSet_Sequence_dec(std::string)(int _size, char **_sequence) {
  SwigSciObject obj = SWIG_SciString_FromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), _sequence, _size);
  delete (char **)_sequence;
  return obj;
}
}

%fragment(SWIG_AsVal_SequenceItem_frag(std::string), "header") {

SWIGINTERN int
SWIG_AsVal_SequenceItem_dec(std::string)(SwigSciObject _obj, char **_pSequence, int _iItemIndex, std::string *_pItemValue) {
  *_pItemValue = std::string(_pSequence[_iItemIndex]);
  return SWIG_OK;
}
}

%fragment(SWIG_From_SequenceItem_frag(std::string), "header") {

SWIGINTERN int
SWIG_From_SequenceItem_dec(std::string)(char **_pSequence, int _iItemIndex, std::string _itemValue) {
  char *pChar = new char(_itemValue.size() + 1);
  strcpy(pChar, _itemValue.c_str());
  _pSequence[_iItemIndex] = pChar;
  return SWIG_OK;
}
}

