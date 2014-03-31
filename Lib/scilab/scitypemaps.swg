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
    return SWIG_ERROR;
  }
}
%enddef

%define %scilab_out_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $1) != SWIG_OK) {
    return SWIG_ERROR;
  }
}
%enddef

%define %scilab_outptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($1)) != SWIG_OK) {
    return SWIG_ERROR;
  }
}
%enddef

%define %scilab_varout_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, $value) != SWIG_OK) {
    return SWIG_ERROR;
  }
}
%enddef

%define %scilab_varoutptr_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $result, %as_voidptr($value)) != SWIG_OK) {
    return SWIG_ERROR;
  }
}
%enddef

%define %scilab_in_typemap(TYPEMAPTYPE, FRAGMENTNAME, CTYPE)
%typemap(TYPEMAPTYPE, noblock=1, fragment="FRAGMENTNAME") CTYPE {
  if (FRAGMENTNAME(pvApiCtx, $input, &$1, fname) != SWIG_OK) {
    return SWIG_ERROR;
  }
}
%enddef

/* Array typmemaps */
%include "sciarray.swg"

/* -----------------------------------------------------------------------------
 * --- Use enum from Scilab ---
 * ----------------------------------------------------------------------------- */
%typemap(in, noblock=1, fragment=SWIG_AsVal_frag(Enum)) enum SWIGTYPE (int val) {
  if (SWIG_AsVal_dec(Enum)($input, &val) != SWIG_OK) {
    return SWIG_ERROR;
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

%define SCILAB_TYPECHECK(TYPE_CHECK_FUNCTION)
  int *piAddrVar = NULL;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  $1 = TYPE_CHECK_FUNCTION(pvApiCtx, piAddrVar);
%enddef

/* Scilab equivalent for C integers can be sci_ints or sci_matrix */
%define SCILAB_INTEGERTYPECHECK(INTTYPE)
  SCILAB_TYPECHECK(isIntegerType)
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
    $1 = isDoubleType(pvApiCtx, piAddrVar);
  }
%enddef


// Double (and Float) have priority over before Integer type.

// Primitive types
%typecheck(SWIG_TYPECHECK_VOIDPTR) SWIGTYPE *                  { SCILAB_TYPECHECK(isPointerType)     }
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *                  { SCILAB_TYPECHECK(isPointerType)     }
%typecheck(SWIG_TYPECHECK_BOOL)    bool                        { SCILAB_TYPECHECK(isBooleanType)     }
%typemap(typecheck, precedence=16) double                      { SCILAB_TYPECHECK(isDoubleType)      }
%typemap(typecheck, precedence=17) float                       { SCILAB_TYPECHECK(isDoubleType)      }
%typecheck(SWIG_TYPECHECK_INT8)    signed char                 { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8)   unsigned char               { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16)   short                       { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16)  unsigned short              { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32)   int, long                   { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32)  unsigned int, unsigned long { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typecheck(SWIG_TYPECHECK_INT32)   enum SWIGTYPE               { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_CHAR)    char                        { SCILAB_TYPECHECK(isStringType)      }

// Arrays
%typecheck(SWIG_TYPECHECK_BOOL_ARRAY)   bool                   { SCILAB_TYPECHECK(isBooleanType)     }
%typemap(typecheck, precedence=1016)    double [ANY]           { SCILAB_TYPECHECK(isDoubleType)      }
%typemap(typecheck, precedence=1017)    float [ANY]            { SCILAB_TYPECHECK(isDoubleType)      }
%typecheck(SWIG_TYPECHECK_INT8_ARRAY)   signed char [ANY]      { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typemap(typecheck, precedence=1026)    unsigned char [ANY]    { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY)  short [ANY]            { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typemap(typecheck, precedence=1036) unsigned short [ANY]      { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY)  int [ANY], long [ANY]  { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typemap(typecheck, precedence=1046) unsigned int [ANY]        { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typemap(typecheck, precedence=1046) unsigned long [ANY]       { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY)   char [ANY]             { SCILAB_TYPECHECK(isStringType)      }
%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char *[ANY], char **   { SCILAB_TYPECHECK(isStringType)      }


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
