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

/* ---------------------------------------------------------------------------*/
/* Generic typmemaps                                                          */
/*                                                                            */
/* This typemap is used when Scilab does not store this type directly         */
/* For example, a 'float' is stored in Scilab as a 'double'                   */
/* So we read a 'double' in Scilab and cast it to a 'float'                   */
/* ---------------------------------------------------------------------------*/

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


/* ---------------------------------------------------------------------------*/
/* Array typmemaps                                                            */
/* ---------------------------------------------------------------------------*/

%include "sciarray.swg"


/* ---------------------------------------------------------------------------*/
/* Enum typemaps                                                              */
/* ---------------------------------------------------------------------------*/

%typemap(in, noblock=1, fragment=SWIG_AsVal_frag(Enum)) enum SWIGTYPE (int val) {
  if (SWIG_AsVal_dec(Enum)($input, &val) != SWIG_OK) {
    return SWIG_ERROR;
  }
  $1 = %reinterpret_cast(val, $ltype);
}

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
%typecheck(SWIG_TYPECHECK_VOIDPTR, noblock=1) SWIGTYPE *                  { SCILAB_TYPECHECK(isPointerType)     }
%typecheck(SWIG_TYPECHECK_POINTER, noblock=1) SWIGTYPE *                  { SCILAB_TYPECHECK(isPointerType)     }
%typecheck(SWIG_TYPECHECK_BOOL, noblock=1)    bool                        { SCILAB_TYPECHECK(isBooleanType)     }
%typemap(typecheck, precedence=16, noblock=1) double                      { SCILAB_TYPECHECK(isDoubleType)      }
%typemap(typecheck, precedence=17, noblock=1) float                       { SCILAB_TYPECHECK(isDoubleType)      }
%typecheck(SWIG_TYPECHECK_INT8, noblock=1)    signed char                 { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8, noblock=1)   unsigned char               { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16, noblock=1)   short                       { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16, noblock=1)  unsigned short              { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32, noblock=1)   int, long                   { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32, noblock=1)  unsigned int, unsigned long { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typecheck(SWIG_TYPECHECK_INT32, noblock=1)   enum SWIGTYPE               { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_CHAR, noblock=1)    char                        { SCILAB_TYPECHECK(isStringType)      }

// Arrays
%typecheck(SWIG_TYPECHECK_BOOL_ARRAY, noblock=1)   bool                   { SCILAB_TYPECHECK(isBooleanType)     }
%typemap(typecheck, precedence=1016, noblock=1)    double [ANY]           { SCILAB_TYPECHECK(isDoubleType)      }
%typemap(typecheck, precedence=1017, noblock=1)    float [ANY]            { SCILAB_TYPECHECK(isDoubleType)      }
%typecheck(SWIG_TYPECHECK_INT8_ARRAY, noblock=1)   signed char [ANY]      { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typemap(typecheck, precedence=1026, noblock=1)    unsigned char [ANY]    { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY, noblock=1)  short [ANY]            { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typemap(typecheck, precedence=1036, noblock=1)    unsigned short [ANY]   { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY, noblock=1)  int [ANY], long [ANY]  { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typemap(typecheck, precedence=1046, noblock=1)    unsigned int [ANY]     { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typemap(typecheck, precedence=1046, noblock=1)    unsigned long [ANY]    { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY, noblock=1)   char [ANY]             { SCILAB_TYPECHECK(isStringType)      }
%typecheck(SWIG_TYPECHECK_STRING_ARRAY, noblock=1) char *[ANY], char **   { SCILAB_TYPECHECK(isStringType)      }


/* ---------------------------------------------------------------------------*/
/* %scilabconstcode() feature typemaps                                        */
/* ---------------------------------------------------------------------------*/

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


/* ---------------------------------------------------------------------------*/
/* Exception typmemaps                                                        */
/* ---------------------------------------------------------------------------*/

%include "sciexception.swg"
