/*
 * C-type: char
 * Scilab type: string
 */

/*
 * CHAR
*/
%fragment(SWIG_AsVal_frag(char), "header", fragment="SwigScilabStringToChar") {
#define SWIG_AsVal_char(scilabValue, valuePointer) SwigScilabStringToChar(pvApiCtx, scilabValue, valuePointer, fname)
}
%fragment("SwigScilabStringToChar", "header") {
SWIGINTERN int
SwigScilabStringToChar(void *_pvApiCtx, int _iVar, char *_pcValue, char *_fname) {
  SciErr sciErr;
  int iType = 0;
  int iRows = 0;
  int iCols = 0;
  int *piAddrVar = NULL;
  char *_pstStrings = NULL;
  int _piLength = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_strings) {
    Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  _pstStrings = (char *)malloc(sizeof(char));
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }
  *_pcValue = _pstStrings[0];

  free(_pstStrings);

  return SWIG_OK;
}
}

%fragment(SWIG_From_frag(char), "header", fragment="SwigScilabStringFromChar") {
#define SWIG_From_char(value) SwigScilabStringFromChar(pvApiCtx, SWIG_Scilab_GetOutputPosition(), value)
}
%fragment("SwigScilabStringFromChar", "header") {
SWIGINTERN int
SwigScilabStringFromChar(void *_pvApiCtx, int _iVarOut, char _chValue) {
  char *pchValue = (char*)malloc(sizeof(char) * 2);
  pchValue[0] = _chValue;
  pchValue[1] = '\0';

  if (createSingleString(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, pchValue))
    return SWIG_ERROR;

  free(pchValue);
  return SWIG_OK;
}
}

/*
 * CHAR *
*/
%fragment("SWIG_AsCharArray", "header", fragment = "SwigScilabStringToCharPtr") {
#define SWIG_AsCharArray(scilabValue, charPtrPointer, charPtrLength) SwigScilabStringToCharPtr(pvApiCtx, scilabValue, charPtrPointer, charPtrLength, fname)
}
%fragment("SWIG_AsCharPtrAndSize", "header", fragment = "SwigScilabStringToCharPtrAndSize") {
#define SWIG_AsCharPtrAndSize(scilabValue, charPtrPointer, charPtrLength, allocMemory) SwigScilabStringToCharPtrAndSize(pvApiCtx, scilabValue, charPtrPointer, charPtrLength, allocMemory, fname)
}
%fragment("SWIG_FromCharPtr", "header", fragment = "SwigScilabStringFromCharPtr") {
#define SWIG_FromCharPtr(charPtr) SwigScilabStringFromCharPtr(pvApiCtx, SWIG_Scilab_GetOutputPosition(), charPtr)
}
%fragment("SWIG_FromCharPtrAndSize", "header", fragment = "SwigScilabStringFromCharPtr") {
#define SWIG_FromCharPtrAndSize(charPtr, charPtrLength) SwigScilabStringFromCharPtr(pvApiCtx, SWIG_Scilab_GetOutputPosition(), charPtr)
}

%fragment("SwigScilabStringToCharPtr", "header") {
SWIGINTERN int
SwigScilabStringToCharPtr(void *_pvApiCtx, int _iVar, char *_pcValue, int _iLength, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  char* pcTmpValue = NULL;
  int iRet;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  iRet = getAllocatedSingleString(_pvApiCtx, piAddrVar, &pcTmpValue);
  if (iRet) {
    return SWIG_ERROR;
  }

  if (_pcValue != NULL) {
    strncpy(_pcValue, pcTmpValue, _iLength);
  }

  free(pcTmpValue);

  return SWIG_OK;
}
}
%fragment("SwigScilabStringToCharPtrAndSize", "header") {
SWIGINTERN int
SwigScilabStringToCharPtrAndSize(void *_pvApiCtx, int _iVar, char **_pcValue, size_t *_piLength, int *alloc, char *_fname) {
  SciErr sciErr;
  int *piAddrVar = NULL;
  int iRet;
  char *pstStrings = NULL;

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  iRet = getAllocatedSingleString(_pvApiCtx, piAddrVar, &pstStrings);
  if (iRet) {
    return SWIG_ERROR;
  }

  // TODO: return SWIG_ERROR if _pcValue NULL (now returning SWIG_ERROR fails some typechecks)
  if (_pcValue)
  {
    *_pcValue = pstStrings;
  }

  if (alloc != NULL) {
    *alloc = SWIG_NEWOBJ;
  }

  if (_piLength != NULL) {
    *_piLength = strlen(*_pcValue);
  }

  return SWIG_OK;
}
}
%fragment("SwigScilabStringFromCharPtr", "header") {
SWIGINTERN int
SwigScilabStringFromCharPtr(void *_pvApiCtx, int _iVarOut, const char *_pchValue) {
  SciErr sciErr;
  char **pstData = NULL;

  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = strdup(_pchValue);

  sciErr = createMatrixOfString(_pvApiCtx, SWIG_NbInputArgument(_pvApiCtx) + _iVarOut, 1, 1, (char **)pstData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  free(pstData[0]);

  return SWIG_OK;
}
}

/*
 * CHAR * ARRAY
*/
%fragment("SwigScilabStringToCharPtrArrayAndSize", "header") {
SWIGINTERN int
SwigScilabStringToCharPtrArrayAndSize(void *_pvApiCtx, int _iVar, char ***_charPtrArray, int* _charPtrArraySize, char *_fname) {
  SciErr sciErr;
  int i = 0;
  int *piAddrVar = NULL;
  int iRows = 0;
  int iCols = 0;
  int* piLength = NULL;

  if ((_charPtrArray == NULL) || (_charPtrArraySize == NULL)) {
    return SWIG_ERROR;
  }

  sciErr = getVarAddressFromPosition(_pvApiCtx, _iVar, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getMatrixOfString(_pvApiCtx, piAddrVar, &iRows, &iCols, NULL, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  piLength = (int*) malloc(iRows * iCols * sizeof(int));

  sciErr = getMatrixOfString(_pvApiCtx, piAddrVar, &iRows, &iCols, piLength, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  *_charPtrArray = (char**) malloc(iRows * iCols * sizeof(char*));
  for(i = 0 ; i < iRows * iCols ; i++)
  {
    (*_charPtrArray)[i] = (char*) malloc(sizeof(char) * (piLength[i] + 1));
  }

  sciErr = getMatrixOfString(_pvApiCtx, piAddrVar, &iRows, &iCols, piLength, *_charPtrArray);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  *_charPtrArraySize = iRows * iCols;

  free(piLength);

  return SWIG_OK;
}
}
%fragment("SwigScilabStringFromCharPtrArray", "header") {
SWIGINTERN int
SwigScilabStringFromCharPtrArray(void *_pvApiCtx, int _iVarOut, char **_charPtrArray, int _charPtrArraySize) {
  SciErr sciErr;

  if (_charPtrArray == NULL) {
    return SWIG_ERROR;
  }

  sciErr = createMatrixOfString(_pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + _iVarOut, _charPtrArraySize, 1, _charPtrArray);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}
}
%fragment(SWIG_CreateScilabVariable_frag(char), "wrapper") {
SWIGINTERN int
SWIG_CreateScilabVariable_dec(char)(void *_pvApiCtx, const char* _psVariableName, const char _cVariableValue) {
  SciErr sciErr;
  char sValue[2];
  const char* psStrings[1];

  sValue[0] = _cVariableValue;
  sValue[1] = '\0';
  psStrings[0] = sValue;

  sciErr = createNamedMatrixOfString(_pvApiCtx, _psVariableName, 1, 1, psStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}
%fragment(SWIG_CreateScilabVariable_frag(charptr), "wrapper") {
SWIGINTERN int
SWIG_CreateScilabVariable_dec(charptr)(void *_pvApiCtx, const char* _psVariableName, const char* _psVariableValue) {
  SciErr sciErr;
  const char* psStrings[1];
  psStrings[0] = _psVariableValue;

  sciErr = createNamedMatrixOfString(_pvApiCtx, _psVariableName, 1, 1, psStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  return SWIG_OK;
}
}
