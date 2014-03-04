/* --------------------------------------------------------------------------
 *
 *  Arrays typemaps
 *
 * --------------------------------------------------------------------------*/

%define %scilab_asarray_withcopy(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPDATATYPE)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  size_t i = 0;
  int iRows = 0;
  int iCols = 0;
  TEMPDATATYPE *pTempData = NULL;
  if (FRAGMENTNAME(pvApiCtx, $input, &iRows, &iCols, &pTempData, fname)) {
    return SWIG_ERROR;
  }
  $1 = ($1_ltype)MALLOC(sizeof($*1_ltype) * iRows * iCols);
  for (i = 0; i < iRows * iCols; i++) {
    $1[i] = ($*1_ltype) pTempData[i];
  }
}
%enddef
%define %scilab_asarrayandsize_withcopy(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPDATATYPE)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  size_t i = 0;
  int iRows = 0;
  int iCols = 0;
  TEMPDATATYPE *pTempData = NULL;
  if (FRAGMENTNAME(pvApiCtx, $input, &iRows, &iCols, &pTempData, fname)) {
    return SWIG_ERROR;
  }
  // TODO: add check to be sure iRows*iCols==$1_dim0
  for (i = 0; i < $1_dim0; i++) {
    $1[i] = ($*1_ltype) pTempData[i];
  }
}
%enddef


/*
 *  Double
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsDoubleArrayAndSize, double[ANY], double);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") double[ANY] {
  %set_output(SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { double[] }; /* double[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsDoubleArrayAndSize, double[], double);


/*
 *  Signed char array
 */

%typemap(in, fragment="SWIG_SciInt8_AsSignedCharArrayAndSize") signed char[] {
  int iRows = 0;
  int iCols = 0;
  if (SWIG_SciInt8_AsSignedCharArrayAndSize(pvApiCtx, $input, &iRows, &iCols, &$1, fname) != SWIG_OK) {
    return 0;
  }
}
%typemap(varin, fragment="SWIG_SciInt8_AsSignedCharArrayAndSize") signed char[] {
  int iRows = 0;
  int iCols = 0;
  if (SWIG_SciInt8_AsSignedCharArrayAndSize(pvApiCtx, $input, &iRows, &iCols, (signed char**)&$1, fname) != SWIG_OK) {
    return 0;
  }
}
%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt8_AsSignedCharArrayAndSize, signed char[ANY], signed char);
%typemap(varout, noblock=1, fragment="SWIG_SciInt8_FromSignedCharArrayAndSize") signed char[ANY] {
  %set_output(SWIG_SciInt8_FromSignedCharArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%typemap(varout, noblock=1, fragment="SWIG_SciInt8_FromSignedCharArrayAndSize") signed char[] {
  %set_output(SWIG_SciInt8_FromSignedCharArrayAndSize(pvApiCtx, $result, 1, strlen((const char*)$1), $1));
}


/*
 *  Unsigned char array
 */

%typemap(in, fragment="SWIG_SciUint8_AsUnsignedCharArrayAndSize") unsigned char[] {
  int iRows = 0;
  int iCols = 0;
  if (SWIG_SciUint8_AsUnsignedCharArrayAndSize(pvApiCtx, $input, &iRows, &iCols, &$1, fname) != SWIG_OK) {
    return 0;
  }
}
%typemap(varin, fragment="SWIG_SciUint8_AsUnsignedCharArrayAndSize") unsigned char[] {
  int iRows = 0;
  int iCols = 0;
  if (SWIG_SciUint8_AsUnsignedCharArrayAndSize(pvApiCtx, $input, &iRows, &iCols, (unsigned char**)&$1, fname) != SWIG_OK) {
    return 0;
  }
}

%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint8_AsUnsignedCharArrayAndSize, unsigned char[ANY], unsigned char);
%typemap(varout, noblock=1, fragment="SWIG_SciUint8_FromUnsignedCharArrayAndSize") unsigned char[ANY] {
  %set_output(SWIG_SciUint8_FromUnsignedCharArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%typemap(varout, noblock=1, fragment="SWIG_SciUint8_FromUnsignedCharArrayAndSize") unsigned char[] {
  %set_output(SWIG_SciUint8_FromUnsignedCharArrayAndSize(pvApiCtx, $result, 1, strlen((const char*)$1), $1));
}


/*
 *  Short array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt16_AsShortArrayAndSize, short[ANY], short);
%typemap(varout, noblock=1, fragment="SWIG_SciInt16_FromShortArrayAndSize") short[ANY] {
  %set_output(SWIG_SciInt16_FromShortArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { short[] }; /* short[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciInt16_AsShortArrayAndSize, short[], short);


/*
 *  Unsigned short array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint16_AsUnsignedShortArrayAndSize, unsigned short[ANY], unsigned short);
%typemap(varout, noblock=1, fragment="SWIG_SciUint16_FromUnsignedShortArrayAndSize") unsigned short[ANY] {
  %set_output(SWIG_SciUint16_FromUnsignedShortArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { unsigned short[] }; /* unsigned short[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciUint16_AsUnsignedShortArrayAndSize, unsigned short[], unsigned short);


/*
 *  Int array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt32_AsIntArrayAndSize, int[ANY], int);
%typemap(varout, noblock=1, fragment="SWIG_SciInt32_FromIntArrayAndSize") int[ANY] {
  %set_output(SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { int[] }; /* int[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciInt32_AsIntArrayAndSize, int[], int);


/*
 *  Unsigned int array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned int[ANY], unsigned int);
%typemap(varout, noblock=1, fragment="SWIG_SciUint32_FromUnsignedIntArrayAndSize") unsigned int[ANY] {
  %set_output(SWIG_SciUint32_FromUnsignedIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { unsigned int[] }; /* unsigned int[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned int[], unsigned int);


/*
 *  Long array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt32_AsIntArrayAndSize, long[ANY], int);
%typemap(varout, noblock=1, fragment="SWIG_SciInt32_FromIntArrayAndSize") long[ANY] {
  %set_output(SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, (const int*) $1));
}
%apply SWIGTYPE[] { long[] }; /* long[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciInt32_AsIntArrayAndSize, long[], int);


/*
 *  Unsigned long array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned long[ANY], unsigned int);
%typemap(varout, noblock=1, fragment="SWIG_SciUint32_AsUnsignedIntArrayAndSize") unsigned long[ANY] {
  %set_output(SWIG_SciUint32_FromUnsignedIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, (unsigned int*) $1));
}
%apply SWIGTYPE[] { unsigned long[] }; /* long[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned long[], unsigned int);


/*
 *  Float array
 */

%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsFloatArrayAndSize, float[ANY], float);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromFloatArrayAndSize") float[ANY] {
  %set_output(SWIG_SciDouble_FromFloatArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { float[] }; /* float[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsFloatArrayAndSize, float[], float);


/*
 *  Bool array
 */

%apply SWIGTYPE[] { bool[] }; /* bool[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciBoolean_AsIntArrayAndSize, bool[], int);


