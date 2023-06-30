/* -------------------------------------------------------------
 * SWIG library containing argc and argv multi-argument typemaps
 * ------------------------------------------------------------- */

%{
SWIGINTERN int SWIG_AsVal_strings (SwigSciObject iVar, int **array, int report) {
  int iType = 0;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, iVar, array);
  if (sciErr.iErr) {
    if (report) printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  sciErr = getVarType(pvApiCtx, *array, &iType);
  if (sciErr.iErr) {
    if (report) printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (iType != sci_strings) {
    /* An empty matrix has type sci_matrix. */
    if (!isEmptyMatrix(pvApiCtx, *array)) {
      return SWIG_TypeError;
    }
    *array = SWIG_NULLPTR;
  }
  return SWIG_OK;
}
%}

%typemap(in) (int ARGC, char **ARGV) {
  SciErr sciErr;
  size_t memsize;
  int i, rows, cols, res, len, *aLen, *array;
  res = SWIG_AsVal_strings ($input, &array, 1);
  if (!SWIG_IsOK(res)) {
    if (res == SWIG_TypeError) {
      SWIG_exception_fail(SWIG_TypeError, "not a string matrix");
    }
    SWIG_fail;
  }

  if (array == SWIG_NULLPTR) {
    /* Special case for empty matrix. */
    $1 = 0;
    $2 = ($2_ltype) malloc(sizeof($*2_ltype));
    $2[0] = SWIG_NULLPTR;
  } else {
    /* first call to retrieve dimensions */
    rows = 0;
    cols = 0;
    sciErr = getMatrixOfString(pvApiCtx, array, &rows, &cols, SWIG_NULLPTR, SWIG_NULLPTR);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      SWIG_fail;
    }
    len = rows * cols;
    memsize = sizeof(int) * len;
    aLen = (int*)malloc(memsize);
    if (aLen == SWIG_NULLPTR) {
      SWIG_exception_fail(SWIG_MemoryError, "fail allocate sizes array");
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
      free((void *)aLen);
      SWIG_exception_fail(SWIG_MemoryError, "fail allocate array");
    }
    memset($2, 0, memsize);
    for(i = 0 ; i < len ; i++) {
      $2[i] = ($*2_ltype)malloc(aLen[i] + 1);
      if ($2[i] == SWIG_NULLPTR) {
        free((void *)aLen);
        SWIG_exception_fail(SWIG_MemoryError, "fail allocate array string element");
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
}

%typemap(typecheck, precedence=SWIG_TYPECHECK_STRING_ARRAY) (int ARGC, char **ARGV) {
  int *array;
  $1 = SWIG_IsOK(SWIG_AsVal_strings ($input, &array, 0));
}

%typemap(freearg) (int ARGC, char **ARGV) {
  if ($2 != SWIG_NULLPTR) {
    $1_ltype i;
    for (i = 0; i < $1; i++) {
      free((void *)$2[i]);
    }
    free((void *)$2);
  }
}
