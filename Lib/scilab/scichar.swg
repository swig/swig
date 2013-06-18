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
  SciErr sciErr;

  char *pchValue = (char*)malloc(sizeof(char) * 2);
  pchValue[0] = _chValue;
  pchValue[1] = '\0';

  sciErr = createMatrixOfString(_pvApiCtx, Rhs + _iVarOut, 1, 1, &pchValue);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  free(pchValue);

  return Rhs + _iVarOut;
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
  int iRows = 0;
  int iCols = 0;
  int iType = 0;
  int *piAddrVar = NULL;
  char *pstStrings = NULL;
  int piLength = 0;

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

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  pstStrings = (char *)malloc(sizeof(char) * (piLength + 1));
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, (char **)&pstStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  strcpy(_pcValue, pstStrings);

  free(pstStrings);

  return SWIG_OK;
}
}
%fragment("SwigScilabStringToCharPtrAndSize", "header") {
SWIGINTERN int
SwigScilabStringToCharPtrAndSize(void *_pvApiCtx, int _iVar, char **_pcValue, size_t *_piLength, int *alloc, char *_fname) {
  SciErr sciErr;
  int iRows = 0;
  int iCols = 0;
  int iType = 0;
  int *piAddrVar = NULL;
  char *_pstStrings = NULL;
  int piLength = 0;

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

  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, NULL);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iRows * iCols != 1) {
    Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), _fname, _iVar);
    return SWIG_ERROR;
  }

  _pstStrings = (char *)malloc(sizeof(char) * (piLength + 1));
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if (alloc) {
    *_pcValue = %new_copy_array(_pstStrings, piLength + 1, char);
    *alloc = SWIG_NEWOBJ;
  } else if (_pcValue) {
    *_pcValue = _pstStrings;
  }

  free(_pstStrings);

  if (_piLength != NULL) {
    *_piLength = (size_t) piLength;
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

  sciErr = createMatrixOfString(_pvApiCtx, Rhs + _iVarOut, 1, 1, (char **)pstData);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  free(pstData[0]);

  return Rhs + _iVarOut;
}
}
