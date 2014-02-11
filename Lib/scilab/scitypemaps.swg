// Scilab fragments for primitive types
%include <sciprimtypes.swg>

%include <scienum.swg>

// Scilab object type
#define SWIG_Object int

#define %append_output(obj)         if (!SWIG_IsOK(SWIG_Scilab_SetOutput(pvApiCtx, obj))) return SWIG_ERROR
#define %set_constant(name, obj)    if (!SWIG_IsOK(SWIG_Scilab_SetOutput(pvApiCtx, obj))) return SWIG_ERROR // Name is managed by the the function name
#define %raise(obj, type, desc)     SWIG_Scilab_Raise(obj, type, desc)
#define %set_output(obj)            if (!SWIG_IsOK(SWIG_Scilab_SetOutput(pvApiCtx, obj))) return SWIG_ERROR
#define %set_varoutput(obj)         if (!SWIG_IsOK(SWIG_Scilab_SetOutput(pvApiCtx, obj))) return SWIG_ERROR
#define %set_argoutput(obj)         if (!SWIG_IsOK(SWIG_Scilab_SetOutput(pvApiCtx, obj))) return SWIG_ERROR

// Include the unified typemap library
%include <typemaps/swigtypemaps.swg>

/* SCILAB GENERIC TYPEMAPS */
/*
 * This typemap is used when Scilab does not store this type directly
 * For example, a 'float' is stored in Scilab as a 'double'
 * So we read a 'double' in Scilab and cast it to a 'float'
 */
%define %scilab_in_typemap_withcast(TYPEMAPTYPE, FRAGMENTNAME, CTYPE, TEMPTYPE, TEMPINIT)
%typemap(TYPEMAPTYPE, fragment="FRAGMENTNAME") CTYPE {
  TEMPTYPE tempValue = TEMPINIT;
  if(FRAGMENTNAME(pvApiCtx, $input, &tempValue, fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
  $1 = (CTYPE) tempValue;
}
%enddef
%define %scilab_inptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $input, %as_voidptrptr(&$1), fname) != SWIG_OK) {
    return 0;
  }
}
%enddef
%define %scilab_out_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $1) != SWIG_OK) {
    return 0;
  }
}
%enddef
%define %scilab_outptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($1)) != SWIG_OK) {
    return 0;
  }
}
%enddef
%define %scilab_varout_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $value) != SWIG_OK) {
    return 0;
  }
}
%enddef
%define %scilab_varoutptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($value)) != SWIG_OK) {
    return 0;
  }
}
%enddef

/************************/
/*** GENERIC TYPEMAPS ***/
/************************/
%define %scilab_in_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $input, &$1, fname) != SWIG_OK) {
    return 0;
  }
}
%enddef
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

/**************/
/*** DOUBLE ***/
/**************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsDoubleArrayAndSize, double[ANY], double);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") double[ANY] {
  %set_output(SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { double[] }; /* double[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsDoubleArrayAndSize, double[], double);

/*******************/
/*** SIGNED CHAR ***/
/*******************/
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

/*********************/
/*** UNSIGNED CHAR ***/
/*********************/
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

/*************/
/*** SHORT ***/
/*************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt16_AsShortArrayAndSize, short[ANY], short);
%typemap(varout, noblock=1, fragment="SWIG_SciInt16_FromShortArrayAndSize") short[ANY] {
  %set_output(SWIG_SciInt16_FromShortArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { short[] }; /* short[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciInt16_AsShortArrayAndSize, short[], short);



/**********************/
/*** UNSIGNED SHORT ***/
/**********************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint16_AsUnsignedShortArrayAndSize, unsigned short[ANY], unsigned short);
%typemap(varout, noblock=1, fragment="SWIG_SciUint16_FromUnsignedShortArrayAndSize") unsigned short[ANY] {
  %set_output(SWIG_SciUint16_FromUnsignedShortArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { unsigned short[] }; /* unsigned short[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciUint16_AsUnsignedShortArrayAndSize, unsigned short[], unsigned short);

/***********/
/*** INT ***/
/***********/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciInt32_AsIntArrayAndSize, int[ANY], int);
%typemap(varout, noblock=1, fragment="SWIG_SciInt32_FromIntArrayAndSize") int[ANY] {
  %set_output(SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { int[] }; /* int[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciInt32_AsIntArrayAndSize, int[], int);

/********************/
/*** UNSIGNED INT ***/
/********************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned int[ANY], unsigned int);
%typemap(varout, noblock=1, fragment="SWIG_SciUint32_FromUnsignedIntArrayAndSize") unsigned int[ANY] {
  %set_output(SWIG_SciUint32_FromUnsignedIntArrayAndSize(pvApiCtx, $result, 1, $1_dim0, $1));
}
%apply SWIGTYPE[] { unsigned int[] }; /* unsigned int[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciUint32_AsUnsignedIntArrayAndSize, unsigned int[], unsigned int);

/*************/
/*** FLOAT ***/
/*************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsDoubleArrayAndSize, float[ANY], double);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") float[ANY] {
  %set_output(SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, $result, 1, $1_dim0, (double*) $1));
}
%apply SWIGTYPE[] { float[] }; /* float[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsDoubleArrayAndSize, float[], double);

/************/
/*** BOOL ***/
/************/
%apply SWIGTYPE[] { bool[] }; /* bool[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciBoolean_AsIntArrayAndSize, bool[], int);

/************/
/*** LONG ***/
/************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsDoubleArrayAndSize, long[ANY], double);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") long[ANY] {
  %set_output(SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, $result, 1, $1_dim0, (double*) $1));
}
%apply SWIGTYPE[] { long[] }; /* long[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsDoubleArrayAndSize, long[], double);

/*********************/
/*** UNSIGNED LONG ***/
/*********************/
%scilab_asarrayandsize_withcopy(varin, SWIG_SciDouble_AsDoubleArrayAndSize, unsigned long[ANY], double);
%typemap(varout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") unsigned long[ANY] {
  %set_output(SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, $result, 1, $1_dim0, (double*) $1));
}
%apply SWIGTYPE[] { unsigned long[] }; /* long[] variables managed as pointers */
%scilab_asarray_withcopy(in, SWIG_SciDouble_AsDoubleArrayAndSize, unsigned long[], double);

/* -----------------------------------------------------------------------------
 * --- Use enum from Scilab ---
 * ----------------------------------------------------------------------------- */
%typemap(in, noblock=1, fragment=SWIG_AsVal_frag(Enum)) enum SWIGTYPE (int val) {
  if (SWIG_AsVal_dec(Enum)($input, &val) != SWIG_OK) {
    return 0;
  }
  $1 = %reinterpret_cast(val, $ltype);
}

/* -----------------------------------------------------------------------------
 * --- Return enum to Scilab ---
 * ----------------------------------------------------------------------------- */
%typemap(out, fragment=SWIG_From_frag(Enum)) enum SWIGTYPE {
  if (SWIG_From_dec(Enum)($1) != SWIG_OK) {
    return SWIG_ERROR;
  }
}

/* ---------------------------------------------------------------------------*/
/* Typecheck typemaps                                                         */
/* ---------------------------------------------------------------------------*/

%define SCILAB_TYPECHECK(TYPE)
  SciErr sciErr;
  int *piAddrVar = NULL;
  int iType = 0;

  sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  $1 = (iType == TYPE) ? 1 : 0;
%enddef

/* Scilab equivalent for C integers can be sci_ints or sci_matrix */
%define SCILAB_INTEGERTYPECHECK(INTTYPE)
  SCILAB_TYPECHECK(sci_ints)
  if ($1 == 1) {
    int iPrec = 0;
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr) {
      printError(&sciErr, 0);
      return SWIG_ERROR;
    }
    $1 = (iPrec == INTTYPE) ? 1 : 0;
  }
  else {
    $1 = (iType == sci_matrix) ? 1 : 0;
  }
%enddef


// Primitive types
%typecheck(SWIG_TYPECHECK_CHAR)    char                        { SCILAB_TYPECHECK(sci_strings)       }
%typecheck(SWIG_TYPECHECK_INT8)    signed char                 { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8)   unsigned char               { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16)   short                       { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16)  unsigned short              { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32)   int, long                   { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32)  unsigned int, unsigned long { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *                  { SCILAB_TYPECHECK(sci_pointer)       }

// Arrays
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY)   char [ANY]                               { SCILAB_TYPECHECK(sci_strings)      }

/* * TODO: add an option to select default integers mapping? */
/* C-integers mapped to Scilab sci_matrix (TODO: add int64 & uint64 for Scilab 6) */
%typecheck(SWIG_TYPECHECK_INT8_ARRAY)   signed char [ANY]                         { SCILAB_TYPECHECK(sci_matrix)      }
//%typecheck(SWIG_TYPECHECK_UINT8_ARRAY)  unsigned char [ANY]                     { SCILAB_TYPECHECK(sci_matrix)      }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY)  short [ANY]                               { SCILAB_TYPECHECK(sci_matrix)      }
//%typecheck(SWIG_TYPECHECK_UINT16_ARRAY) unsigned short [ANY]                    { SCILAB_TYPECHECK(sci_matrix)      }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY)  int [ANY], long [ANY]                     { SCILAB_TYPECHECK(sci_matrix)      }
//%typecheck(SWIG_TYPECHECK_UINT32_ARRAY) unsigned int [ANY], unsigned long [ANY] { SCILAB_TYPECHECK(sci_matrix)      }
/* C-integers mapped to Scilab integers (TODO: add int64 & uint64 for Scilab 6) */
/*
%typecheck(SWIG_TYPECHECK_INT8_ARRAY)   signed char [ANY]                       { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8_ARRAY)  unsigned char [ANY]                     { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY)  short [ANY]                             { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16_ARRAY) unsigned short [ANY]                    { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY)  int [ANY], long [ANY]                   { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32_ARRAY) unsigned int [ANY], unsigned long [ANY] { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
*/

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) double [ANY]                            { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY)  float [ANY]                             { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_BOOL_ARRAY)   bool                                    { SCILAB_TYPECHECK(sci_boolean)       }
%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char **                                 { SCILAB_TYPECHECK(sci_strings)       }

/* -----------------------------------------------------------------------------*/
/* Constants and enums to Scilab variables
/* -----------------------------------------------------------------------------*/

%typemap(scilabconstcode, fragment=SWIG_CreateScilabVariable_frag(int)) int
%{
  if (SWIG_CreateScilabVariable_int(pvApiCtx, "$result", $value) != SWIG_OK)
    return SWIG_ERROR;
%}

%typemap(scilabconstcode, fragment=SWIG_CreateScilabVariable_frag(double)) double
%{
  if (SWIG_CreateScilabVariable_double(pvApiCtx, "$result", $value) != SWIG_OK)
    return SWIG_ERROR;
%}

%typemap(scilabconstcode, fragment=SWIG_CreateScilabVariable_frag(char)) char
%{
  if (SWIG_CreateScilabVariable_char(pvApiCtx, "$result", $value) != SWIG_OK)
    return SWIG_ERROR;
%}

%typemap(scilabconstcode, fragment=SWIG_CreateScilabVariable_frag(charptr)) char *
%{
  if (SWIG_CreateScilabVariable_charptr(pvApiCtx, "$result", $value) != SWIG_OK)
    return SWIG_ERROR;
%}

%typemap(scilabconstcode, fragment=SWIG_CreateScilabVariable_frag(double)) enum SWIGTYPE
%{
  if (SWIG_CreateScilabVariable_double(pvApiCtx, "$result", $value) != SWIG_OK)
    return SWIG_ERROR;
%}
