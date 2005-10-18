%include <typemaps/primtypes.swg>

/* Macro for 'signed long' derived types */

%define %type_slong(Type, Frag, Min, Max)
%derived_type_from(long, Type)
%signed_derived_type_asval(long, Type, Frag, Min, Max)
%enddef

/* Macro for 'unsigned long' derived types */

%define %type_ulong(Type, Frag, Max)
%derived_type_from(unsigned long, Type)
%unsigned_derived_type_asval(unsigned long, Type, Frag, Max)
%enddef

/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(SWIG_From_frag(bool),"header") {
SWIGINTERNINLINE PyObject*
  SWIG_From_dec(bool)(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(bool)(PyObject *obj, bool *val)
{
  if (obj == Py_True) {
    if (val) *val = true;
    return SWIG_OK;
  } else if (obj == Py_False) {
    if (val) *val = false;
    return SWIG_OK;
  } else {
    long v = 0;
    int res = SWIG_AsVal(long)(obj, &v);
    if (res == SWIG_OK && val) *val = v ? true : false;
    return res;
  }
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
  SWIG_define(SWIG_From_dec(long),           PyInt_FromLong)
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long)(PyObject *obj, long* val)
{
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    long v = PyLong_AsLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}

/* unsigned long */

%fragment(SWIG_From_frag(unsigned long),"header",
	  fragment=SWIG_From_frag(long)) {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) : PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long)(PyObject *obj, unsigned long *val) 
{
  if (PyInt_Check(obj)) {
    long v = PyInt_AsLong(obj);
    if (v >= 0) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      return SWIG_OverflowError;
    }
  } else if (PyLong_Check(obj)) {
    unsigned long v = PyLong_AsUnsignedLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}

/* long long */

%fragment(SWIG_From_frag(long long),"header",
	  fragment=SWIG_From_frag(long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(long long)(long long value)
{
  return ((value < LONG_MIN) || (value > LONG_MAX)) ?
    PyLong_FromLongLong(value) : PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGINTERN int
SWIG_AsVal_dec(long long)(PyObject *obj, long long *val)
{
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    long long v = PyLong_AsLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  } 
  return SWIG_TypeError;
}
}

/* unsigned long long */

%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment=SWIG_From_frag(long long),
	  fragment="<limits.h>") {
SWIGINTERNINLINE PyObject* 
SWIG_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : PyInt_FromLong(SWIG_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGINTERN int
SWIG_AsVal_dec(unsigned long long)(PyObject *obj, unsigned long long *val)
{
  if (PyLong_Check(obj)) {
    unsigned long long v = PyLong_AsUnsignedLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  } else {
    unsigned long v;
    int res = SWIG_AsVal(unsigned long)(obj,&v);
    if (res == SWIG_OK && val) *val = v;
    return res;
  }
  return SWIG_TypeError;
}
}

/* float */

%derived_type_from(double, float)
%signed_derived_type_asval(double, float, "<float.h>", -FLT_MAX, FLT_MAX)

/* double */

%fragment(SWIG_From_frag(double),"header") {
  SWIG_define(SWIG_From_dec(double),          PyFloat_FromDouble)
}

%fragment(SWIG_AsVal_frag(double),"header") {
SWIGINTERN int
SWIG_AsVal_dec(double)(PyObject *obj, double *val)
{
  if (PyFloat_Check(obj)) {
    if (val) *val = PyFloat_AsDouble(obj);
    return SWIG_OK;
  } else if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return SWIG_OK;
  } else if (PyLong_Check(obj)) {
    double v = PyLong_AsDouble(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return SWIG_OK;
    } else {
      PyErr_Clear();
    }
  }
  return SWIG_TypeError;
}
}

/* char */

%fragment(SWIG_From_frag(char),"header") {
SWIGINTERNINLINE PyObject*
SWIG_From_dec(char)(char c) 
{ 
  return PyString_FromStringAndSize(&c,1);
}
}

%fragment(SWIG_AsVal_frag(char),"header",
	  fragment="SWIG_AsCharArray",
	  fragment=SWIG_AsVal_frag(signed char)) {
SWIGINTERN int
SWIG_AsVal_dec(char)(PyObject *obj, char *val)
{
  if (SWIG_AsCharArray(obj, val, 1) == SWIG_OK) {
    return SWIG_OK;
  } else {
    signed char v;
    int res = SWIG_AsVal(signed char)(obj, &v);
    if (res == SWIG_OK && val) *val = (char)(v);
    return res;
  }
 }
}

/* wchar_t */


%fragment(SWIG_From_frag(wchar_t),"header") {
SWIGINTERNINLINE PyObject*
SWIG_From_dec(wchar_t)(wchar_t c) 
{ 
  return PyUnicode_FromWideChar(&c, 1);
}
}

%fragment(SWIG_AsVal_frag(wchar_t),"header",
	  fragment="SWIG_AsWCharArray",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGINTERN int
SWIG_AsVal_dec(wchar_t)(PyObject *obj, wchar_t *val)
{
  if (SWIG_AsWCharArray(obj, val, 1) == SWIG_OK) {
    return SWIG_OK;
  } else {
    long v;
    int res = SWIG_AsVal(long)(obj, &v);
    if (res == SWIG_OK) {
      if (WCHAR_MIN <= v && v <= WCHAR_MAX) {
	if (val) *val = (wchar_t)(v);
	return SWIG_OK;
      } else {
	return SWIG_OverflowError;
      }
    }
    return res;
  }
}
}

/* ------------------------------------------------------------
 * Apply the primitive typemap for all the types with checkcode
 * ------------------------------------------------------------ */

%apply_checkctypes(%typemap_primitive)
