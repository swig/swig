/* --------------------------------------------------------------------------
 *
 *  Arrays typemaps
 *
 * --------------------------------------------------------------------------*/

%{
#include <stdio.h>
%}

%define %scilab_asarray_withallocatecopy(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPDATATYPE)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  size_t i = 0;
  int iRows = 0;
  int iCols = 0;
  int iAllocated = 0;
  TEMPDATATYPE *pTempData = NULL;
  if (FRAGMENTNAME(pvApiCtx, $input, &iRows, &iCols, &pTempData, &iAllocated, fname)) {
    SWIG_fail;
  }
  $1 = ($1_ltype)MALLOC(sizeof($*1_ltype) * iRows * iCols);
  if ($1 == NULL) {
    if (iAllocated) free(pTempData);
    SWIG_exception_fail(SWIG_MemoryError, "Fail to allocate array");
  }
  for (i = 0; i < iRows * iCols; i++) {
    $1[i] = ($*1_ltype) pTempData[i];
  }
  if (iAllocated) free(pTempData);
}
%enddef

%define %scilab_asarrayandsize_withcopy(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPDATATYPE)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  int iRows = 0;
  int iCols = 0;
  int iAllocated = 0;
  TEMPDATATYPE *pTempData = NULL;
  if (FRAGMENTNAME(pvApiCtx, $input, &iRows, &iCols, &pTempData, &iAllocated, fname)) {
    SWIG_fail;
  }
  if (iRows*iCols <= $1_dim0) {
    size_t i;
    for (i = 0; i < $1_dim0; i++) {
      $1[i] = ($*1_ltype) pTempData[i];
    }
  }
  else {
    char errmsg[100];
    if (iAllocated) free(pTempData);
    SWIG_snprintf2(errmsg, sizeof(errmsg), "Size of input data (%d) is too big (maximum is %d)",
                   iRows*iCols, $1_dim0);
    SWIG_exception_fail(SWIG_OverflowError, errmsg);
  }
  if (iAllocated) free(pTempData);
}
%enddef

%define %scilab_fromarrayandsize(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  %set_output(FRAGMENTNAME(pvApiCtx, $result, 1, $1_dim0, $1));
}
%enddef

%define %scilab_array_typemaps(CTYPE, ASARRAY_FRAGMENT, FROMARRAY_FRAGMENT, TEMPDATATYPE)
  %scilab_asarrayandsize_withcopy(varin, ASARRAY_FRAGMENT, CTYPE[ANY], TEMPDATATYPE);
  %scilab_asarray_withallocatecopy(in, ASARRAY_FRAGMENT, CTYPE[ANY], TEMPDATATYPE);
  %scilab_fromarrayandsize(varout, FROMARRAY_FRAGMENT, CTYPE[ANY]);
  %scilab_fromarrayandsize(out, FROMARRAY_FRAGMENT, CTYPE[ANY]);

  %apply SWIGTYPE[] { CTYPE[] };
  %scilab_asarray_withallocatecopy(in, ASARRAY_FRAGMENT, CTYPE[], TEMPDATATYPE);
  %typemap(freearg) CTYPE[ANY] {
    FREE($1);
  }
  %typemap(freearg) CTYPE[] {
    FREE($1);
  }
%enddef


// Double
%scilab_array_typemaps(double, SWIG_SciDouble_AsDoubleArrayAndSize,
  SWIG_SciDouble_FromDoubleArrayAndSize, double);

// Signed char

%scilab_array_typemaps(signed char, SWIG_SciDoubleOrInt8_AsSignedCharArrayAndSize,
  SWIG_SciDouble_FromSignedCharArrayAndSize, signed char);

// Unsigned char
%scilab_array_typemaps(unsigned char, SWIG_SciDoubleOrUint8_AsUnsignedCharArrayAndSize,
  SWIG_SciDouble_FromUnsignedCharArrayAndSize, unsigned char);

// Short
%scilab_array_typemaps(short, SWIG_SciDoubleOrInt16_AsShortArrayAndSize,
  SWIG_SciDouble_FromShortArrayAndSize, short);

// Unsigned short
%scilab_array_typemaps(unsigned short, SWIG_SciDoubleOrUint16_AsUnsignedShortArrayAndSize,
  SWIG_SciDouble_FromUnsignedShortArrayAndSize, unsigned short);

// Int
%scilab_array_typemaps(int, SWIG_SciDoubleOrInt32_AsIntArrayAndSize,
  SWIG_SciDouble_FromIntArrayAndSize, int);

// Unsigned int
%scilab_array_typemaps(unsigned int, SWIG_SciDoubleOrUint32_AsUnsignedIntArrayAndSize,
  SWIG_SciDouble_FromUnsignedIntArrayAndSize, unsigned int);

// Long
%scilab_array_typemaps(long, SWIG_SciDoubleOrInt32_AsIntArrayAndSize,
  SWIG_SciDouble_FromLongArrayAndSize, int);

// Unsigned long
%scilab_array_typemaps(unsigned long, SWIG_SciDoubleOrUint32_AsUnsignedIntArrayAndSize,
  SWIG_SciDouble_FromUnsignedLongArrayAndSize, unsigned int);

// Float
%scilab_array_typemaps(float, SWIG_SciDouble_AsFloatArrayAndSize,
  SWIG_SciDouble_FromFloatArrayAndSize, float);

// Bool
%scilab_array_typemaps(bool, SWIG_SciBoolean_AsIntArrayAndSize,
  SWIG_SciBoolean_FromBoolArrayAndSize, int);

// Char *
// The Scilab string fragment always allocates the char* array and every
// string, so the freearg typemaps have to release each element as well
%typemap(varin, fragment="SWIG_SciString_AsCharPtrArrayAndSize") char *[ANY] (int iRows, int iCols, int iAllocated) {
  char **pTempData = NULL;
  size_t i;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &iRows, &iCols, &pTempData, &iAllocated, fname)) {
    SWIG_fail;
  }
  if (iRows*iCols > $1_dim0) {
    char errmsg[100];
    if (iAllocated) {
      for (i = 0; i < (size_t)(iRows*iCols); i++) free(pTempData[i]);
      free(pTempData);
    }
    SWIG_snprintf2(errmsg, sizeof(errmsg), "Size of input data (%d) is too big (maximum is %d)",
                   iRows*iCols, $1_dim0);
    SWIG_exception_fail(SWIG_OverflowError, errmsg);
  }
  for (i = 0; i < (size_t)(iRows*iCols); i++) {
    $1[i] = (char *) malloc(strlen(pTempData[i]) + 1);
    if ($1[i] == NULL) {
      SWIG_exception_fail(SWIG_MemoryError, "Fail to allocate string array");
    }
    strcpy($1[i], pTempData[i]);
  }
  if (iAllocated) {
    for (i = 0; i < (size_t)(iRows*iCols); i++) free(pTempData[i]);
    free(pTempData);
  }
}
%typemap(in, fragment="SWIG_SciString_AsCharPtrArrayAndSize") char *[ANY] (size_t iLen=0, int iRows=0, int iCols=0, int iAllocated=0) {
  char **pTempData = NULL;
  size_t i = 0;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &iRows, &iCols, &pTempData, &iAllocated, fname)) {
    SWIG_fail;
  }
  if (iRows*iCols > $1_dim0) {
    char errmsg[100];
    if (iAllocated) {
      for (i = 0; i < (size_t)(iRows*iCols); i++) free(pTempData[i]);
      free(pTempData);
    }
    SWIG_snprintf2(errmsg, sizeof(errmsg), "Size of input data (%d) is too big (maximum is %d)",
                   iRows*iCols, $1_dim0);
    SWIG_exception_fail(SWIG_OverflowError, errmsg);
  }
  iLen = (size_t) iRows * (size_t) iCols;
  $1 = ($1_ltype)MALLOC(sizeof($*1_ltype) * iLen);
  if ($1 == NULL) {
    if (iAllocated) {
      for (i = 0; i < iLen; i++) free(pTempData[i]);
      free(pTempData);
    }
    iLen = 0;
    SWIG_exception_fail(SWIG_MemoryError, "Fail to allocate string array");
  }
  for (i = 0; i < iLen; i++) {
    $1[i] = ($*1_ltype) pTempData[i];
  }
  if (iAllocated) free(pTempData);
}
%scilab_fromarrayandsize(varout, SWIG_SciString_FromCharPtrArrayAndSize, char *[ANY]);
%scilab_fromarrayandsize(out, SWIG_SciString_FromCharPtrArrayAndSize, char *[ANY]);

%apply SWIGTYPE[] { char *[] };
%typemap(in, fragment="SWIG_SciString_AsCharPtrArrayAndSize") char *[] (size_t iLen=0, int iRows=0, int iCols=0, int iAllocated=0) {
  char **pTempData = NULL;
  size_t i = 0;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &iRows, &iCols, &pTempData, &iAllocated, fname)) {
    SWIG_fail;
  }
  iLen = (size_t) iRows * (size_t) iCols;
  $1 = ($1_ltype)MALLOC(sizeof($*1_ltype) * iLen);
  if ($1 == NULL) {
    if (iAllocated) {
      for (i = 0; i < iLen; i++) free(pTempData[i]);
      free(pTempData);
    }
    iLen = 0;
    SWIG_exception_fail(SWIG_MemoryError, "Fail to allocate string array");
  }
  for (i = 0; i < iLen; i++) {
    $1[i] = ($*1_ltype) pTempData[i];
  }
  if (iAllocated) free(pTempData);
}
%typemap(freearg) char *[ANY] {
  size_t i;
  for (i = 0; i < iLen$argnum; i++) {
    free($1[i]);
  }
  FREE($1);
}
%typemap(freearg) char *[] {
  size_t i;
  for (i = 0; i < iLen$argnum; i++) {
    free($1[i]);
  }
  FREE($1);
}

