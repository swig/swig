/* ------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------ */

%{
SWIGINTERN int SWIG_AsVal_strings (SwigSciObject iVar, int **array) {
  int iType = 0;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, iVar, array);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  sciErr = getVarType(pvApiCtx, *array, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_strings) {
    SWIG_exception_fail(SWIG_TypeError, "not a string matrix");
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  SciErr sciErr;
  size_t memsize;
  int i, rows, cols, res, len, *aLen, *array;
  res = SWIG_AsVal_strings ($input, &array);
  if (!SWIG_IsOK(res)) {
    SWIG_fail;
  }
  /* first call to retrieve dimensions */
  rows = 0;
  cols = 0;
  sciErr = getMatrixOfString(pvApiCtx, array, &rows, &cols, SWIG_NULLPTR, SWIG_NULLPTR);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    SWIG_fail;
  }
  len = rows * cols;
  SWIG_contract_assert(len > 0, "array must contain at least 1 element");
  memsize = sizeof(int) * len;
  aLen = (int*)malloc(memsize);
  if (aLen == SWIG_NULLPTR) {
    SWIG_exception_fail(SWIG_MemoryError, "fail allocate sizes array");
    SWIG_fail;
  }
  memset(aLen, 0, memsize);
  /*second call to retrieve length of each string */
  sciErr = getMatrixOfString(pvApiCtx, array, &rows, &cols, aLen, SWIG_NULLPTR);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    free((void *)aLen);
    SWIG_fail;
  }
  memsize = sizeof($*2_ltype) * (len + 1);
  $1 = ($1_ltype) len;
  $2 = ($2_ltype) malloc(memsize);
  if ($2 == SWIG_NULLPTR) {
    SWIG_exception_fail(SWIG_MemoryError, "fail allocate array");
    free((void *)aLen);
    SWIG_fail;
  }
  memset($2, 0, memsize);
  for(i = 0 ; i < len ; i++) {
    $2[i] = ($*2_ltype)malloc(aLen[i] + 1);
    if ($2[i] == SWIG_NULLPTR) {
      SWIG_exception_fail(SWIG_MemoryError, "fail allocate array string element");
      free((void *)aLen);
      SWIG_fail;
    }
  }
  /* third call to retrieve data */
  sciErr = getMatrixOfString(pvApiCtx, array, &rows, &cols, aLen, $2);
  if(sciErr.iErr) {
      printError(&sciErr, 0);
      free((void *)aLen);
      SWIG_fail;
  }
  $2[len] = SWIG_NULLPTR;
  free((void *)aLen);
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  int *array, res = SWIG_AsVal_strings ($input, &array);
  if (SWIG_IsOK(res)) {
    int rows = 0, cols = 0;
    SciErr sciErr = getMatrixOfString(pvApiCtx, array, &rows, &cols, SWIG_NULLPTR, SWIG_NULLPTR);
    if (!sciErr.iErr && (rows * cols) > 0) {
      $1 = 1;
    }
  }
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != SWIG_NULLPTR) {
    $1_ltype i;
    for (i = 0; i < $1; i++) {
      if ($2[i] != SWIG_NULLPTR) {
        free((void *)$2[i]);
      }
    }
    free((void *)$2);
  }
}
