/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/*
  Define the SWIG_As/From methods for the basic types.  In many
  cases, these method are just aliases of the original python As/From
  methods. In the other cases, some extra work is needed.
*/

%fragment(SWIG_From_frag(signed char),"header") {
  SWIG_define(SWIG_From(signed char),    PyInt_FromLong)
}

%fragment(SWIG_From_frag(unsigned char),"header") {
  SWIG_define(SWIG_From(unsigned char),  PyInt_FromLong)
}

%fragment(SWIG_From_frag(short),"header") {
  SWIG_define(SWIG_From(short),          PyInt_FromLong)
}

%fragment(SWIG_From_frag(unsigned short),"header") {
  SWIG_define(SWIG_From(unsigned short), PyInt_FromLong)
}

%fragment(SWIG_From_frag(int),"header") {
  SWIG_define(SWIG_From(int),            PyInt_FromLong)
}

%fragment(SWIG_From_frag(long),"header") {
  SWIG_define(SWIG_From(long),           PyInt_FromLong)
}

%fragment(SWIG_From_frag(float),"header") {
  SWIG_define(SWIG_From(float),          PyFloat_FromDouble)
}

%fragment(SWIG_From_frag(double),"header") {
  SWIG_define(SWIG_From(double),         PyFloat_FromDouble)
}

/*
  Here, we have all the complex AsVal/From methods
*/

%fragment("<limits.h>","header") %{
#include <limits.h>
%}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int
  SWIG_AsVal(unsigned long)(PyObject *obj, unsigned long *val) 
{
  if (PyInt_Check(obj)) {
    long v = PyInt_AS_LONG(obj);
    if (v >= 0) {
      if (val) *val = v;
      return 1;
    }   
  }
  if (PyLong_Check(obj)) {
    unsigned long v = PyLong_AsUnsignedLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return 1;
    } else {
      if (!val) PyErr_Clear();
      return 0;
    }
  } 
  if (val) {
    SWIG_type_error("unsigned long", obj);
  }
  return 0;
}
}

%fragment("SWIG_CheckLongInRange","header",
	  fragment="<limits.h>") {
SWIGINTERN int
  SWIG_CheckLongInRange(long value, long min_value, long max_value,
			const char *errmsg)
{
  if (value < min_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError, 
		   "value %ld is less than '%s' minimum %ld", 
		   value, errmsg, min_value);
    }
    return 0;    
  } else if (value > max_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError,
		   "value %ld is greater than '%s' maximum %ld", 
		   value, errmsg, max_value);
    }
    return 0;
  }
  return 1;
}
}

%fragment("SWIG_CheckUnsignedLongInRange","header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE int
  SWIG_CheckUnsignedLongInRange(unsigned long value,
				unsigned long max_value,
				const char *errmsg) 
{
  if (value > max_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError,
		   "value %lu is greater than '%s' minimum %lu",
		   value, errmsg, max_value);
    }
    return 0;
  }
  return 1;
 }
}


%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
  SWIG_AsVal(double)(PyObject *obj, double *val)
{
  if (PyFloat_Check(obj)) {
    if (val) *val = PyFloat_AS_DOUBLE(obj);
    return 1;
  }  
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AS_LONG(obj);
    return 1;
  }
  if (PyLong_Check(obj)) {
    double v = PyLong_AsDouble(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return 1;
    } else {
      if (!val) PyErr_Clear();
      return 0;
    }
  }
  if (val) {
    SWIG_type_error("double", obj);
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int
  SWIG_AsVal(long)(PyObject * obj, long* val)
{
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AS_LONG(obj);
    return 1;
  }
  if (PyLong_Check(obj)) {
    long v = PyLong_AsLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return 1;
    } else {
      if (!val) PyErr_Clear();
      return 0;
    }
  }
  if (val) {
    SWIG_type_error("long", obj);
  }
  return 0;
 }
}


%fragment(SWIG_From_frag(long long),"header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
  SWIG_From(long long)(long long value)
{
  return ((value < LONG_MIN) || (value > LONG_MAX)) ?
    PyLong_FromLongLong(value)
    : PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}


%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
  SWIG_From(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : 
    PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int
  SWIG_AsVal(long long)(PyObject *obj, long long *val)
{
  if (PyLong_Check(obj)) {
    long long v = PyLong_AsLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return 1;
    } else {
      if (!val) PyErr_Clear();
      return 0;
    }
  }
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AS_LONG(obj);
    return 1;
  }
  if (val) {
    SWIG_type_error("long long", obj);
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGINTERN int
  SWIG_AsVal(unsigned long long)(PyObject *obj, unsigned long long *val)
{
  unsigned long v;
  if (PyLong_Check(obj)) {
    unsigned long long v = PyLong_AsUnsignedLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return 1;
    } else {
      if (!val) PyErr_Clear();
      return 0;
    }
  }
  if (SWIG_AsVal(unsigned long)(obj,&v)) {
    if (val) *val = v;
    return 1;
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error("unsigned long long", obj);
  }  
  return 0;
}
}

%fragment(SWIG_From_frag(unsigned long),"header") {
SWIGINTERNINLINE PyObject* 
  SWIG_From(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) 
    : PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(signed char),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
  SWIG_AsVal(signed char)(PyObject *obj, signed char *val)
{
  const char* errmsg = val ? "signed char" : (char*) 0;
  long v;
  if (SWIG_AsVal(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, SCHAR_MIN, SCHAR_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, signed char);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }  
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;    
}
}

%fragment(SWIG_AsVal_frag(short),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
  SWIG_AsVal(short)(PyObject *obj, short *val)
{ 
  const char* errmsg = val ? "short" : (char*)0;
  long v;
  if (SWIG_AsVal(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, SHRT_MIN, SHRT_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, short);
      return 1;
    } else {
      return 0;
    }    
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;    
}
}

/* need range checks */

%fragment(SWIG_AsVal_frag(int),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
%#if INT_MAX != LONG_MAX
SWIGINTERN int
  SWIG_AsVal(int)(PyObject *obj, int *val)
{ 
  const char* errmsg = val ? "int" : (char*)0;
  long v;
  if (SWIG_AsVal(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, INT_MIN,INT_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, int);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;    
}
%#else
SWIGINTERNINLINE int
  SWIG_AsVal(int)(PyObject *obj, int *val)
{
  return SWIG_AsVal(long)(obj,(long*)val);
}
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned int),"header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
%#if UINT_MAX != ULONG_MAX
SWIGINTERN int
  SWIG_AsVal(unsigned int)(PyObject *obj, unsigned int *val)
{ 
  const char* errmsg = val ? "unsigned int" : (char*)0;
  unsigned long v;
  if (SWIG_AsVal(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, INT_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, unsigned int);
      return 1;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;    
}
%#else
SWIGINTERNINLINE unsigned int
  SWIG_AsVal(unsigned int)(PyObject *obj, unsigned int *val)
{
  return SWIG_AsVal(unsigned long)(obj,(unsigned long *)val);
}
%#endif
}

%fragment(SWIG_From_frag(unsigned int),"header",
	  fragment=SWIG_From_frag(long),
	  fragment=SWIG_From_frag(unsigned long)) {
%#if UINT_MAX < LONG_MAX
SWIG_define(SWIG_From(unsigned int), SWIG_From(long))
%#else
SWIG_define(SWIG_From(unsigned int), SWIG_From(unsigned long))
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned char),"header",
	  fragment=SWIG_AsVal_frag(unsigned long),
	  fragment="SWIG_CheckUnsignedLongInRange") {
SWIGINTERN int
  SWIG_AsVal(unsigned char)(PyObject *obj, unsigned char *val)
{ 
  const char* errmsg = val ? "unsigned char" : (char*)0;
  unsigned long v;
  if (SWIG_AsVal(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, UCHAR_MAX,errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, unsigned char);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(unsigned short),"header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGINTERN int
  SWIG_AsVal(unsigned short)(PyObject *obj, unsigned short *val)
{ 
  const char* errmsg = val ? "unsigned short" : (char*)0;
  unsigned long v;
  if (SWIG_AsVal(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, USHRT_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, unsigned short);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;
}
}


%fragment("SWIG_CheckDoubleInRange","header") {
%#include <float.h>
SWIGINTERN int
  SWIG_CheckDoubleInRange(double value, double min_value, 
			  double max_value, const char* errmsg)
{
  if (value < min_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError, 
		   "value %g is less than %s minimum %g", 
		   value, errmsg, min_value);
    }
    return 0;
  } else if (value > max_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError, 
		   "value %g is greater than %s maximum %g", 
		   value, errmsg, max_value);
    }
    return 0;
  }
  return 1;
}
}

%fragment(SWIG_AsVal_frag(float),"header",
	  fragment="SWIG_CheckDoubleInRange",
	  fragment=SWIG_AsVal_frag(double)) {
SWIGINTERN int
  SWIG_AsVal(float)(PyObject *obj, float *val)
{
  const char* errmsg = val ? "float" : (char*)0;
  double v;
  if (SWIG_AsVal(double)(obj, &v)) {
    if (SWIG_CheckDoubleInRange(v, -FLT_MAX, FLT_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, float);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    SWIG_type_error(errmsg, obj);
  }
  return 0;
}
}

%fragment(SWIG_From_frag(char),"header") {
SWIGINTERNINLINE PyObject*
  SWIG_From(char)(char c) 
{ 
  return PyString_FromStringAndSize(&c,1);
}
}

%fragment(SWIG_AsVal_frag(char),"header",
	  fragment="SWIG_AsCharArray",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
  SWIG_AsVal(char)(PyObject *obj, char *val)
{
  const char* errmsg = val ? "char" : (char*)0;
  long v;
  if (SWIG_AsVal(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, CHAR_MIN,CHAR_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, char);
      return 1;
    } else {
      return 0;
    }    
  } else {
    PyErr_Clear();
    return SWIG_AsCharArray(obj, val, 1);
  }
 }
}

%fragment(SWIG_From_frag(wchar_t),"header") {
SWIGINTERNINLINE PyObject*
  SWIG_From(wchar_t)(wchar_t c) 
{ 
  return PyUnicode_FromWideChar(&c, 1);
}
}

%fragment(SWIG_AsVal_frag(wchar_t),"header",
	  fragment="SWIG_AsWCharArray",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
%#include <wchar.h>
SWIGINTERN int
  SWIG_AsVal(wchar_t)(PyObject *obj, wchar_t *val)
{
  const char* errmsg = val ? "wchar_t" : (char*)0;
  long v;
  if (SWIG_AsVal(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, WCHAR_MIN, WCHAR_MAX, errmsg)) {
      if (val) *val = SWIG_numeric_cast(v, wchar_t);
      return 1;
    } else {
      return 0;
    }    
  } else {
    PyErr_Clear();
    return SWIG_AsWCharArray(obj, val, 1);
  }
 }
}

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE PyObject*
  SWIG_From(bool)(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(int)) {
SWIGINTERN int
  SWIG_AsVal(bool)(PyObject *obj, bool *val)
{
  if (obj == Py_True) {
    if (val) *val = true;
    return 1;
  }
  if (obj == Py_False) {
    if (val) *val = false;
    return 1;
  }
  int res = 0;
  if (SWIG_AsVal(int)(obj, &res)) {    
    if (val) *val = res ? true : false;
    return 1;
  } else {
    PyErr_Clear();
  }  
  if (val) {
    SWIG_type_error("bool", obj);
  }
  return 0;
}
}


/* ------------------------------------------------------------
 * typemap for primitive type with no pointer representation 
 * ------------------------------------------------------------ */

%define %typemap_primitive(Code, ...)
%typemap_asvalfromn(SWIG_arg(Code), __VA_ARGS__);
%enddef
 


/* ------------------------------------------------------------
 * Primitive Type Macros
 * ------------------------------------------------------------ */

/* useful macros to derive typemap declarations from primitive types */

%define _apply_macro(macro, arg, ...)
#if #__VA_ARGS__ != ""
  macro(__VA_ARGS__,arg);
#else
  macro(arg);
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
_apply_macro(Macro, std::complex<float>    , __VA_ARGS__);
_apply_macro(Macro, std::complex<double>   , __VA_ARGS__);
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
 * Apply the primitive typemap for all the types with checkcode
 * ------------------------------------------------------------ */

%apply_checkctypes(%typemap_primitive)


