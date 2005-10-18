/* ------------------------------------------------------------
 * typemap for primitive type with no pointer representation 
 * ------------------------------------------------------------ */

%define %typemap_primitive(Code, Type...)
%typemap_asvalfromn(SWIG_arg(Code), Type);
%enddef

/* ------------------------------------------------------------
 * Primitive Type Macros
 * ------------------------------------------------------------ */

/* useful macros to derive typemap declarations from primitive types */

%define _apply_macro(macro, arg2, arg1...)
#if #arg1 != ""
  macro(SWIG_arg(arg1),arg2);
#else
  macro(arg2);
#endif
%enddef

/* Apply macro to the order types */
%define %apply_ctypes(Macro,...)
_apply_macro(Macro, bool               , __VA_ARGS__);
_apply_macro(Macro, signed char        , __VA_ARGS__);
_apply_macro(Macro, unsigned char      , __VA_ARGS__);
_apply_macro(Macro, short              , __VA_ARGS__);
_apply_macro(Macro, unsigned short     , __VA_ARGS__);
_apply_macro(Macro, int                , __VA_ARGS__);
_apply_macro(Macro, unsigned int       , __VA_ARGS__);
_apply_macro(Macro, long               , __VA_ARGS__);
_apply_macro(Macro, unsigned long      , __VA_ARGS__);
_apply_macro(Macro, long long          , __VA_ARGS__);
_apply_macro(Macro, unsigned long long , __VA_ARGS__);
_apply_macro(Macro, float              , __VA_ARGS__);
_apply_macro(Macro, double             , __VA_ARGS__);
_apply_macro(Macro, char               , __VA_ARGS__);
_apply_macro(Macro, wchar_t            , __VA_ARGS__);
%enddef

/* apply the Macro(Type) to all the C++ types  */
%define %apply_cpptypes(Macro,...)
%apply_ctypes(Macro, __VA_ARGS__)
_apply_macro(Macro, std::string, __VA_ARGS__);
_apply_macro(Macro, std::complex<float>, __VA_ARGS__);
_apply_macro(Macro, std::complex<double>, __VA_ARGS__);
%enddef

/* apply the Macro2(Type1, Type2) to all the C++ types  */
%define %apply_cpptypes_2(Macro2)
%apply_cpptypes(%apply_cpptypes, Macro2)
%enddef

%define %apply_checkctypes(Macro)
Macro(SWIG_CCode(BOOL),    bool);
Macro(SWIG_CCode(INT8),    signed char);
Macro(SWIG_CCode(UINT8),   unsigned char);
Macro(SWIG_CCode(INT16),   short);
Macro(SWIG_CCode(UINT16),  unsigned short);
Macro(SWIG_CCode(INT32),   int);
Macro(SWIG_CCode(UINT32),  unsigned int);
Macro(SWIG_CCode(INT64),   long);
Macro(SWIG_CCode(UINT64),  unsigned long);
Macro(SWIG_CCode(INT128),  long long);
Macro(SWIG_CCode(UINT128), unsigned long long);
Macro(SWIG_CCode(FLOAT),   float);
Macro(SWIG_CCode(DOUBLE),  double);
Macro(SWIG_CCode(CHAR),    char);
Macro(SWIG_CCode(UNICHAR), wchar_t);
%enddef



/* ------------------------------------------------------------
 * common fragments and macro helpers
 * ------------------------------------------------------------ */


%fragment("<limits.h>","header") %{
#include <limits.h>
%}

%fragment("<wchar.h>","header") %{
#include <wchar.h>
%}

%fragment("<float.h>","header") %{
#include <float.h>
%}

/* Macros for derived types */

%define %derived_type_from(Base, Type)
%fragment(SWIG_From_frag(Type),"header",
	  fragment=SWIG_From_frag(Base)) {
  SWIG_define(SWIG_From_dec(Type),  SWIG_From_dec(Base))
}
%enddef

%define %derived_type_asval(Base, Type, Frag, OverflowCond)
%check_swig_object()

%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=Frag,
	  fragment=SWIG_AsVal_frag(Base)) {
SWIGINTERN int
SWIG_AsVal_dec(Type)(SWIG_Object obj, Type *val)
{
  Base v;
  int res = SWIG_AsVal(Base)(obj, &v);
  if (res == SWIG_OK) {
    if (OverflowCond) {
      return SWIG_OverflowError;
    } else {
      if (val) *val = SWIG_numeric_cast(v, Type);
      return SWIG_OK;
    }
  }  
  return res;
}
}
%enddef

%define %signed_derived_type_asval(Base, Type, Frag, Min, Max)
%derived_type_asval(Base, Type, Frag, (v < Min || v > Max))
%enddef

%define %unsigned_derived_type_asval(Base, Type, Frag, Max)
%derived_type_asval(Base, Type, Frag, (v > Max))
%enddef

