%include <typemaps/primtypes.swg>

/* Macro for 'signed long' derived types */

%define %type_slong(Type, Frag, Min, Max)
%derived_type_from(long, Type)
%fragment("Tcl_asval_"{Type},"header",fragment=Frag) %{
%tcl_asval_decl(Type)
%}
%signed_derived_type_asval(long, Type, "Tcl_asval_"{Type} , Min, Max)
%enddef

/* Macro for 'unsigned long' derived types */

%define %type_ulong(Type, Frag, Max)
%derived_type_from(unsigned long, Type)
%fragment("Tcl_asval_"{Type},"header",fragment=Frag) %{
%tcl_asval_decl(Type)
%}
%unsigned_derived_type_asval(unsigned long, Type, "Tcl_asval_"{Type}, Max)
%enddef

/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
  SWIG_define(SWIG_From_dec(bool),           Tcl_NewBooleanObj)
}

%fragment(SWIG_AsVal_frag(bool),"header") {
%tcl_asval_decl(bool)

SWIGINTERN int
SWIG_AsVal_dec(bool)(Tcl_Obj *obj, bool *val)
{
  int v;
  if (Tcl_GetBooleanFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v ? true : false;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* signed/unsigned char */

%type_slong(signed char,     "<limits.h>", SCHAR_MIN, SCHAR_MAX)
%type_ulong(unsigned char,   "<limits.h>", UCHAR_MAX)

/* short/unsigned short */

%type_slong(short,           "<limits.h>", SHRT_MIN, SHRT_MAX)
%type_ulong(unsigned short,  "<limits.h>", USHRT_MAX)

/* int/unsigned int */

%type_slong(int,             "<limits.h>", INT_MIN, INT_MAX)
%type_ulong(unsigned int,    "<limits.h>", UINT_MAX)

/* signed/unsigned wchar_t */

#ifdef __cplusplus
%type_slong(signed wchar_t,   "<wchar.h>", WCHAR_MIN, WCHAR_MAX)
%type_ulong(unsigned wchar_t, "<wchar.h>", UWCHAR_MAX)
#endif


/* long */

%fragment(SWIG_From_frag(long),"header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(long)(long value)
{
  if (((long) INT_MIN <= value) && (value <= (long) INT_MAX)) {
    return Tcl_NewIntObj(SWIG_numeric_cast(value,int));
  } else {
    return Tcl_NewLongObj(value);
  }
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
%tcl_asval_decl(long)

SWIGINTERN int
SWIG_AsVal_dec(long)(Tcl_Obj *obj, long* val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = (long) v;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(unsigned long)(unsigned long value)
{
  if (value < (unsigned long) LONG_MAX) {
    return SWIG_From(long)(SWIG_numeric_cast(value, long));
  } else {
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%lu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
%tcl_asval_decl(unsigned long)

SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(Tcl_Obj *obj, unsigned long *val) {
  int len = 0;
  const char *nptr = Tcl_GetStringFromObj(obj, &len);
  if (nptr && len > 0) {
    char *endptr;
    unsigned long v = strtoul(nptr, &endptr,0);
    if (errno == ERANGE) {
      errno = 0;
      return SWIG_OverflowError;
    } else {
      if (*endptr == '\0') {
	if (val) *val = v;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(long long)(long long value)
{
  if (((long long) LONG_MIN <= value) && (value <= (long long) LONG_MAX)) {
    return SWIG_From(long)(SWIG_numeric_cast(value,long));
  } else {    
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%lld", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
%tcl_asval_decl(long long)

SWIGINTERN int
SWIG_AsVal_dec(long long)(Tcl_Obj *obj, long long *val)
{
  int len = 0;
  const char *nptr = Tcl_GetStringFromObj(obj, &len);
  if (nptr && len > 0) {
    char *endptr;
    long long v = strtoll(nptr, &endptr,0);
    if (errno == ERANGE) {
      errno = 0;
      return SWIG_OverflowError;
    } else {
      if (*endptr == '\0') {
	if (val) *val = v;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE Tcl_Obj* 
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  if (value < (unsigned long long) LONG_MAX) {
    return SWIG_From(long long)(SWIG_numeric_cast(value, long long));
  } else {
    char temp[256]; 
    snprintf(temp, sizeof(temp),"%llu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
%tcl_asval_decl(unsigned long long)

SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(Tcl_Obj *obj, unsigned long long *val)
{
  int len = 0;
  const char *nptr = Tcl_GetStringFromObj(obj, &len);
  if (nptr && len > 0) {
    char *endptr;
    unsigned long long v = strtoull(nptr, &endptr,0);
    if (errno == ERANGE) {
      errno = 0;
      return SWIG_OverflowError;
    } else {
      if (*endptr == '\0') {
	if (val) *val = v;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

/* float */

%derived_type_from(double, float)
%fragment("Tcl_asval_float","header",fragment="<float.h>") {
%tcl_asval_decl(float)
}
%signed_derived_type_asval(double, float, "Tcl_asval_float", -FLT_MAX, FLT_MAX)

/* double */

%fragment(SWIG_From_frag(double),"header") {
  SWIG_define(SWIG_From_dec(double),         Tcl_NewDoubleObj)
}

%fragment(SWIG_AsVal_frag(double),"header") {
%tcl_asval_decl(double)

SWIGINTERN int
SWIG_AsVal_dec(double)(Tcl_Obj *obj, double *val)
{
  double v;
  if (Tcl_GetDoubleFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v;
    return SWIG_OK;
  }
  return SWIG_TypeError;
}
}

/* char */

%fragment(SWIG_From_frag(char),"header") {
SWIGINTERNINLINE Tcl_Obj*
SWIG_From_dec(char)(char c) 
{ 
  return Tcl_NewStringObj(&c,1);
}
}

%fragment(SWIG_AsVal_frag(char),"header",
	  fragment="SWIG_AsCharArray",
	  fragment=SWIG_AsVal_frag(signed char)) {
%tcl_asval_decl(char)

SWIGINTERNINLINE int
SWIG_AsVal_dec(char)(Tcl_Obj *obj, char *val)
{    
  return SWIG_AsCharArray(obj, val, 1) == SWIG_OK ? SWIG_OK : SWIG_TypeError;
}
}


/* wchar_t */

%fragment(SWIG_From_frag(wchar_t),"header") {
SWIGINTERNINLINE Tcl_Obj*
SWIG_From_dec(wchar_t)(wchar_t c) 
{ 
  return Tcl_NewUnicodeObj(&c, 1);
}
}

%fragment(SWIG_AsVal_frag(wchar_t),"header",
	  fragment="SWIG_AsWCharArray",
	  fragment="<wchar.h>",
	  fragment=SWIG_AsVal_frag(long)) {
%tcl_asval_decl(wchar_t)

SWIGINTERNINLINE int
SWIG_AsVal_dec(wchar_t)(Tcl_Obj *obj, wchar_t *val)
{
  return (SWIG_AsWCharArray(obj, val, 1) == SWIG_OK) ? SWIG_OK : SWIG_TypeError;
}
}

/* ------------------------------------------------------------
 * Apply the primitive typemap for all the types with checkcode
 * ------------------------------------------------------------ */

%apply_checkctypes(%typemap_primitive)
