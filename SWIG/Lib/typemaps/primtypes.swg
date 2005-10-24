/* ------------------------------------------------------------
 * Basic fragments derived from long and double types
 * ------------------------------------------------------------ */

/* signed/unsigned char */

%numeric_slong(signed char,     "<limits.h>", SCHAR_MIN, SCHAR_MAX)
%numeric_ulong(unsigned char,   "<limits.h>", UCHAR_MAX)

/* short/unsigned short */

%numeric_slong(short,           "<limits.h>", SHRT_MIN, SHRT_MAX)
%numeric_ulong(unsigned short,  "<limits.h>", USHRT_MAX)

/* int/unsigned int */

%numeric_slong(int,             "<limits.h>", INT_MIN, INT_MAX)
%numeric_ulong(unsigned int,    "<limits.h>", UINT_MAX)

/* signed/unsigned wchar_t */

#ifdef __cplusplus
%numeric_slong(signed wchar_t,   "<wchar.h>", WCHAR_MIN, WCHAR_MAX)
%numeric_ulong(unsigned wchar_t, "<wchar.h>", UWCHAR_MAX)
#endif

/* float */

%numeric_double(float,           "<float.h>", -FLT_MAX, FLT_MAX)


/* ------------------------------------------------------------
 * typemap macro for primitive types with asval/from methods
 * ------------------------------------------------------------ */

%define %typemaps_primitive(Code, Type)
  %typemaps_asvalfromn(%arg(Code), Type);
%enddef

/* ------------------------------------------------------------
 * Primitive Type Macros
 * ------------------------------------------------------------ */

/* useful macros to derive typemap declarations from primitive types */

%define _apply_macro(macro, arg2, arg1...)
#if #arg1 != ""
  macro(%arg(arg1),arg2);
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
Macro(%checkcode(BOOL),    bool);
Macro(%checkcode(INT8),    signed char);
Macro(%checkcode(UINT8),   unsigned char);
Macro(%checkcode(INT16),   short);
Macro(%checkcode(UINT16),  unsigned short);
Macro(%checkcode(INT32),   int);
Macro(%checkcode(UINT32),  unsigned int);
Macro(%checkcode(INT64),   long);
Macro(%checkcode(UINT64),  unsigned long);
Macro(%checkcode(INT128),  long long);
Macro(%checkcode(UINT128), unsigned long long);
Macro(%checkcode(FLOAT),   float);
Macro(%checkcode(DOUBLE),  double);
Macro(%checkcode(CHAR),    char);
Macro(%checkcode(UNICHAR), wchar_t);
%enddef


/* ------------------------------------------------------------
 * Apply the primitive typemap for all the types with checkcode
 * ------------------------------------------------------------ */

%apply_checkctypes(%typemaps_primitive);

