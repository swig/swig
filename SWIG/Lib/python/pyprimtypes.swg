/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/*
  Define the SWIGAs/From methods for the basic types.  In many
  cases, these method are just aliases of the original python As/From
  methods. In the other cases, some extra work is needed.
*/


%insert(header) {
SWIG_define(SWIG_From_meth(signed char),    PyInt_FromLong);
SWIG_define(SWIG_From_meth(unsigned char),  PyInt_FromLong);
SWIG_define(SWIG_From_meth(short),          PyInt_FromLong);
SWIG_define(SWIG_From_meth(unsigned short), PyInt_FromLong);
SWIG_define(SWIG_From_meth(int),            PyInt_FromLong);
SWIG_define(SWIG_From_meth(long),           PyInt_FromLong);
SWIG_define(SWIG_From_meth(float),          PyFloat_FromDouble);
SWIG_define(SWIG_From_meth(double),         PyFloat_FromDouble);
SWIG_define(SWIG_From_meth(float),          PyFloat_FromDouble);
SWIG_define(SWIG_From_meth(double),         PyFloat_FromDouble);
}

%fragment("<limits.h>","header") %{
#include <limits.h>
%}

%fragment(SWIG_AsVal_frag(unsigned long),"header") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(unsigned long)(PyObject * obj, unsigned long *val) 
{
  if (PyLong_Check(obj)) {
    if (val) *val = PyLong_AsUnsignedLong(obj);
    return 1;
  } 
  if (PyInt_Check(obj)) {
    long v = PyInt_AsLong(obj);
    if (v >= 0) {
      if (val) *val = v;
      return 1;
    }   
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a unsigned long is expected");
  }
  return 0;
}
}

%fragment("SWIG_CheckLongInRange","header",
	  fragment="<limits.h>") {
SWIGSTATICINLINE(int)
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
SWIGSTATICINLINE(int)
  SWIG_CheckUnsignedLongInRange(unsigned long value,
				unsigned long max_value,
				const char *errmsg) 
{
  if (value > max_value) {
    if (errmsg) {
      PyErr_Format(PyExc_OverflowError,
		   "value %ld is greater than '%s' minimum %ld",
		   value, errmsg, max_value);
    }
    return 0;
  }
  return 1;
 }
}


%fragment(SWIG_AsVal_frag(double),"header") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(double)(PyObject *obj, double *val)
{
  if (PyFloat_Check(obj)) {
    if (val) *val = PyFloat_AsDouble(obj);
    return 1;
  }  
  if (PyLong_Check(obj)) {
    if (val) *val = PyLong_AsDouble(obj);
    return 1;
  }
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return 1;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a double is expected");
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(long)(PyObject * obj, long* val)
{
  if (PyLong_Check(obj)) {
    if (val) *val = PyLong_AsLong(obj);
    return 1;
  }
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return 1;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a long is expected");
  }
  return 0;
 }
}


%fragment(SWIG_From_frag(long long),"header",
	  fragment="<limits.h>") {
SWIGSTATICINLINE(PyObject* )
  SWIG_From_meth(long long)(long long value)
{
  return ((value < LONG_MIN) || (value > LONG_MAX)) ?
    PyLong_FromLongLong(value)
    : PyInt_FromLong(swig_numeric_cast(value,long)); 
}
}


%fragment(SWIG_From_frag(unsigned long long),"header",
	  fragment="<limits.h>") {
SWIGSTATICINLINE(PyObject* )
  SWIG_From_meth(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : 
    PyInt_FromLong(swig_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(long long),"header") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(long long)(PyObject *obj, long long *val)
{
  if (PyLong_Check(obj)) {
    if (val) *val = PyLong_AsLongLong(obj);
    return 1;
  }
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return 1;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a long long is expected");
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(unsigned long long),"header",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(unsigned long long)(PyObject *obj, unsigned long long *val)
{
  if (PyLong_Check(obj)) {
    if (val) *val = PyLong_AsUnsignedLongLong(obj);
    return 1;
  }
  unsigned long v;
  if (SWIG_AsVal_meth(unsigned long)(obj,&v)) {
    if (val) *val = v;
    return 1;
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a long long is expected");
  }  
  return 0;
}
}

%fragment(SWIG_From_frag(unsigned long),"header") {
SWIGSTATICINLINE(PyObject* )
  SWIG_From_meth(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) 
    : PyInt_FromLong(swig_numeric_cast(value,long)); 
}
}

%fragment(SWIG_AsVal_frag(signed char),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(signed char)(PyObject *obj, signed char *val)
{
  const char* errmsg = val ? "signed char" : 0;
  long v;
  if (SWIG_AsVal_meth(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, SCHAR_MIN, SCHAR_MAX, errmsg)) {
      if (val) *val = swig_numeric_cast(v, signed char);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }  
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a signed char is expected");
  }
  return 0;    
}
}

%fragment(SWIG_AsVal_frag(short),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(short)(PyObject *obj, short *val)
{ 
  const char* errmsg = val ? "short" : 0;
  long v;
  if (SWIG_AsVal_meth(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, SHRT_MIN, SHRT_MAX, errmsg)) {
      if (val) *val = swig_numeric_cast(v, short);
      return 1;
    } else {
      return 0;
    }    
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a short is expected");
  }
  return 0;    
}
}

/* need range checks */

%fragment(SWIG_AsVal_frag(int),"header",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
%#if INT_MAX != LONG_MAX
SWIGSTATICINLINE(int)
SWIG_AsVal_meth(int)(PyObject *obj, int *val)
{ 
  const char* errmsg = val ? "int" : 0;
  long v;
  if (SWIG_AsVal_meth(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, INT_MIN,INT_MAX, errmsg)) {
      if (val) *val = swig_numeric_cast(v, int);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a int is expected");
  }
  return 0;    
}
%#else
SWIGSTATICINLINE(int)
SWIG_AsVal_meth(int)(PyObject *obj, int *val)
{
  return SWIG_AsVal_meth(long)(obj,(long*)val);
}
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned int),"header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
%#if UINT_MAX != ULONG_MAX
SWIGSTATICINLINE(int)
SWIG_AsVal_meth(unsigned int)(PyObject *obj, unsigned int *val)
{ 
  const char* errmsg = val ? "unsigned int" : 0;
  unsigned long v;
  if (SWIG_AsVal_meth(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, INT_MAX, errmsg)) {
      if (val) *val = swig_numeric_cast(v, unsigned int);
      return 1;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a unsigned int is expected");
  }
  return 0;    
}
%#else
SWIGSTATICINLINE(unsigned int)
  SWIG_AsVal_meth(unsigned int)(PyObject *obj, unsigned int *val)
{
  return SWIG_AsVal_meth(unsigned long)(obj,(unsigned long *)val);
}
%#endif
}

%fragment(SWIG_From_frag(unsigned int),"header",
	  fragment=SWIG_From_frag(long),
	  fragment=SWIG_From_frag(unsigned long)) {
%#if UINT_MAX < LONG_MAX
SWIG_define(SWIG_From_meth(unsigned int),   SWIG_From_meth(long));
%#else
SWIG_define(SWIG_From_meth(unsigned int),   SWIG_From_meth(unsigned long));
%#endif
}

%fragment(SWIG_AsVal_frag(unsigned char),"header",
	  fragment=SWIG_AsVal_frag(unsigned long),
	  fragment="SWIG_CheckUnsignedLongInRange") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(unsigned char)(PyObject *obj, unsigned char *val)
{ 
  const char* errmsg = val ? "unsigned char" : 0;
  unsigned long v;
  if (SWIG_AsVal_meth(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, UCHAR_MAX,errmsg)) {
      if (val) *val = swig_numeric_cast(v, unsigned char);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a unsigned char is expected");
  }
  return 0;
}
}

%fragment(SWIG_AsVal_frag(unsigned short),"header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment=SWIG_AsVal_frag(unsigned long)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(unsigned short)(PyObject *obj, unsigned short *val)
{ 
  const char* errmsg = val ? "unsigned short" : 0;
  unsigned long v;
  if (SWIG_AsVal_meth(unsigned long)(obj, &v)) {
    if (SWIG_CheckUnsignedLongInRange(v, USHRT_MAX, errmsg)) {
      if (val) *val = swig_numeric_cast(v, unsigned short);
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a unsigned short is expected");
  }
  return 0;
}
}


%fragment("SWIG_CheckDoubleInRange","header") {
%#include <float.h>

SWIGSTATIC(int)
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
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(float)(PyObject *obj, float *val)
{
  const char* errmsg = val ? "float" : 0;
  double v;
  if (SWIG_AsVal_meth(double)(obj, &v)) {
    if (SWIG_CheckDoubleInRange(v, FLT_MIN, FLT_MAX, errmsg)) {
      if (val) *val = v;
      return 1;
    } else {
      return 0;
    }
  } else {
    PyErr_Clear();
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a float is expected");
  }
  return 0;
}
}

%fragment(SWIG_From_frag(char),"header") {
SWIGSTATICINLINE(PyObject*)
  SWIG_From_meth(char)(char c) 
{ 
  return PyString_FromStringAndSize(&c,1);
}
}

%fragment(SWIG_AsVal_frag(char),"header",
	  fragment="SWIG_AsCharArray",
	  fragment="SWIG_CheckLongInRange",
	  fragment=SWIG_AsVal_frag(long)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(char)(PyObject *obj, char *val)
{
  const char* errmsg = val ? "char" : 0;
  long v;
  if (SWIG_AsVal_meth(long)(obj, &v)) {
    if (SWIG_CheckLongInRange(v, CHAR_MIN,CHAR_MAX, errmsg)) {
      if (val) *val = v;
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

%fragment(SWIG_From_frag(bool),"header") {
SWIGSTATICINLINE(PyObject*)
  SWIG_From_meth(bool)(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
}

%fragment(SWIG_AsVal_frag(bool),"header",
	  fragment=SWIG_AsVal_frag(int)) {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(bool)(PyObject *obj, bool *val)
{
  /*  if (val) *val = PyObject_IsTrue(obj); return 1; */
  if (obj == Py_True) {
    if (val) *val = true;
    return 1;
  }
  if (obj == Py_False) {
    if (val) *val = false;
    return 1;
  }
  int res;
  if (SWIG_AsVal_meth(int)(obj, &res)) {    
    if (val) *val = (bool)res;
    return 1;
  }
  if (val) {
    PyErr_SetString(PyExc_TypeError, "a float is expected");
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
 
%typemap_primitive(SWIG_CCode(BOOL),    bool);
%typemap_primitive(SWIG_CCode(INT8),    signed char);
%typemap_primitive(SWIG_CCode(UINT8),   unsigned char);
%typemap_primitive(SWIG_CCode(INT16),   short);
%typemap_primitive(SWIG_CCode(UINT16),  unsigned short);
%typemap_primitive(SWIG_CCode(INT32),   int);
%typemap_primitive(SWIG_CCode(UINT32),  unsigned int);
%typemap_primitive(SWIG_CCode(INT64),   long);
%typemap_primitive(SWIG_CCode(UINT64),  unsigned long);
%typemap_primitive(SWIG_CCode(INT128),  long long);
%typemap_primitive(SWIG_CCode(UINT128), unsigned long long);
%typemap_primitive(SWIG_CCode(FLOAT),   float);
%typemap_primitive(SWIG_CCode(DOUBLE),  double);
%typemap_primitive(SWIG_CCode(CHAR),    char);


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
%define %apply_otypes(Macro,...)
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
%enddef

/* apply the Macro(Type) to all the C types  */
%define %apply_ctypes(Macro,...)
%apply_otypes(Macro, __VA_ARGS__)
_apply_macro(Macro, bool, __VA_ARGS__);
%enddef

/* apply the Macro(Type) to all the C++ types  */
%define %apply_cpptypes(Macro,...)
%apply_otypes(Macro, __VA_ARGS__)
_apply_macro(Macro, bool, __VA_ARGS__);
_apply_macro(Macro, std::string, __VA_ARGS__);
_apply_macro(Macro, std::complex<float>, __VA_ARGS__);
_apply_macro(Macro, std::complex<double>, __VA_ARGS__);
%enddef

/* apply the Macro2(Type1, Type2) to all the C++ types  */
%define %apply_cpptypes_2(Macro2)
%apply_cpptypes(%apply_cpptypes, Macro2)
%enddef

