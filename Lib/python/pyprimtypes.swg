/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/*
  Define the SWIGAs/From methods for the basic types.  In many
  cases, these method are just aliases of the original python As/From
  methods. In the other cases, some extra work is needed.
*/

/*
  no wrapped found needed here... yet,
  and we define the names  SWIG for consistency
 */ 

%{
#define SWIG_FromSignedChar     PyInt_FromLong
#define SWIG_FromUnsignedChar   PyInt_FromLong
#define SWIG_FromShort         PyInt_FromLong
#define SWIG_FromUnsignedShort  PyInt_FromLong
#define SWIG_FromInt           PyInt_FromLong
#define SWIG_FromLong          PyInt_FromLong
#define SWIG_FromFloat         PyFloat_FromDouble
#define SWIG_FromDouble        PyFloat_FromDouble
#define SWIG_FromFloat         PyFloat_FromDouble
#define SWIG_FromDouble        PyFloat_FromDouble
%}

%fragment("<limits.h>","header") %{
#include <limits.h>
%}

%fragment("SWIG_AsUnsignedLong","header") %{
SWIGSTATICINLINE(unsigned long)
SWIG_AsUnsignedLong(PyObject * obj) 
{
  if (PyLong_Check(obj)) {
    return PyLong_AsUnsignedLong(obj);
  } else {
    long i = PyInt_AsLong(obj);
    if ( !PyErr_Occurred() && (i < 0)) {
      PyErr_SetString(PyExc_TypeError, "negative value for unsigned type");
    }
    return i;
  }
}
%}

%fragment("SWIG_CheckLongInRange","header",
	  fragment="<limits.h>") %{
SWIGSTATICINLINE(long)
SWIG_CheckLongInRange(long value, const char* type,
		      long min_value, long max_value)
{
  if (!PyErr_Occurred()) {
    if (value < min_value) {
      PyObject *err = 
	PyString_FromFormat("value %ld is less than '%s' minimum %ld", 
			    value, type, min_value);
      
      PyErr_SetObject(PyExc_OverflowError, err);
      Py_DECREF(err);
    } else if (value > max_value) {
      PyObject *err = 
	PyString_FromFormat("value %ld is greater than '%s' maximum %ld", 
			    value, type, max_value);
      PyErr_SetObject(PyExc_OverflowError, err);
      Py_DECREF(err);
    }
  }
  return value;
}
%}

%fragment("SWIG_CheckUnsignedLongInRange","header",
	  fragment="<limits.h>") %{
SWIGSTATICINLINE(unsigned long)
SWIG_CheckUnsignedLongInRange(unsigned long value, const char* type,
			      unsigned long max_value) 
{
  if (!PyErr_Occurred()) {
    if (value > max_value) {     
      PyObject *err =
	PyString_FromFormat("value %ld is greater than '%s' minimum %ld",
			    value, type, max_value);
      PyErr_SetObject(PyExc_OverflowError, err);
      Py_DECREF(err);
    }
  }
  return value;
}
%}


%fragment("SWIG_AsDouble","header") %{
SWIGSTATICINLINE(double)
SWIG_AsDouble(PyObject *obj)
{
  double val = (PyFloat_Check(obj)) ? PyFloat_AsDouble(obj) :
#if HAVE_LONG_LONG
    ((PyInt_Check(obj)) ? PyInt_AsLong(obj) : PyLong_AsLongLong(obj));
#else
    ((PyInt_Check(obj)) ? PyInt_AsLong(obj) : PyLong_AsLong(obj));
#endif
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a double is expected");
  }
  return val;
}
%}

%fragment("SWIG_AsLong","header") %{
SWIGSTATICINLINE(long)
SWIG_AsLong(PyObject * obj)
{
  return PyInt_Check(obj) ? PyInt_AsLong(obj) : PyLong_AsLong(obj);
}
%}

%fragment("SWIG_FromLongLong","header",
	  fragment="<limits.h>") %{
SWIGSTATICINLINE(PyObject* )
SWIG_FromLongLong(long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromLongLong(value)
    : PyInt_FromLong(swig_numeric_cast(long,value)); 
}
%}

%fragment("SWIG_FromUnsignedLongLong","header",
	  fragment="<limits.h>") %{
SWIGSTATICINLINE(PyObject* )
SWIG_FromUnsignedLongLong(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : 
    PyInt_FromLong(swig_numeric_cast(long, value)); 
}
%}

%fragment("SWIG_AsLongLong","header") %{
SWIGSTATICINLINE(long long)
SWIG_AsLongLong(PyObject *obj)
{
  return PyInt_Check(obj) ? 
    PyInt_AsLong(obj) : PyLong_AsLongLong(obj);
}
%}

%fragment("SWIG_AsUnsignedLongLong","header",
	  fragment="SWIG_AsUnsignedLong") %{
SWIGSTATICINLINE(unsigned long long)
SWIG_AsUnsignedLongLong(PyObject *obj)
{
  return PyLong_Check(obj) ?
    PyLong_AsUnsignedLongLong(obj) : SWIG_AsUnsignedLong(obj);
}
%}

%fragment("SWIG_FromUnsignedLong","header") %{
SWIGSTATICINLINE(PyObject* )
SWIG_FromUnsignedLong(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) 
    : PyInt_FromLong(swig_numeric_cast(long,value)); 
}
%}

%fragment("SWIG_AsSignedChar","header",
	  fragment="SWIG_CheckLongInRange",
	  fragment="SWIG_AsLong") %{
SWIGSTATICINLINE(signed char)
SWIG_AsSignedChar(PyObject *obj)
{ 
  return swig_numeric_cast(signed char,
    SWIG_CheckLongInRange(SWIG_AsLong(obj),
			  "signed char", SCHAR_MIN, SCHAR_MAX));
}
%}

%fragment("SWIG_AsShort","header",
	  fragment="SWIG_CheckLongInRange",
	  fragment="SWIG_AsLong") %{
SWIGSTATICINLINE(short)
SWIG_AsShort(PyObject *obj)
{ 
  return swig_numeric_cast(short,
    SWIG_CheckLongInRange(SWIG_AsLong(obj),
			  "short", SHRT_MIN, SHRT_MAX));
}
%}

/* need range checks */

%fragment("SWIG_AsInt","header",
	  fragment="SWIG_CheckLongInRange",
	  fragment="SWIG_AsLong") %{
#if INT_MAX != LONG_MAX
SWIGSTATICINLINE(int)
SWIG_AsInt(PyObject *obj)
{ 
  return swig_numeric_cast(int,
    SWIG_CheckLongInRange(SWIG_AsLong(obj),
			  "int", INT_MIN, INT_MAX));
}
#else
#define SWIG_AsInt SWIG_AsLong
#endif
%}
%fragment("SWIG_AsUnsignedInt","header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment="SWIG_AsUnsignedLong") %{
#if UINT_MAX != ULONG_MAX
SWIGSTATICINLINE(unsigned int)
SWIG_AsUnsignedInt(PyObject *obj)
{ 
  return swig_numeric_cast(unsigned int,
    SWIG_CheckUnsignedLongInRange(SWIG_AsUnsignedLong(obj),
				  "unsigned int", UINT_MAX));
}
#else
#define SWIG_AsUnsignedInt SWIG_AsUnsignedLong
#endif
%}

%fragment("SWIG_FromUnsignedInt","header",
	  fragment="SWIG_FromUnsignedLong") %{
#if UINT_MAX < LONG_MAX
#define SWIG_FromUnsignedInt    SWIG_FromLong
#else
#define SWIG_FromUnsignedInt    SWIG_FromUnsignedLong
#endif
%}


%fragment("SWIG_AsUnsignedChar","header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment="SWIG_AsUnsignedLong") %{
SWIGSTATICINLINE(unsigned char)
SWIG_AsUnsignedChar(PyObject *obj)
{ 
  return swig_numeric_cast(unsigned char,
    SWIG_CheckUnsignedLongInRange(SWIG_AsUnsignedLong(obj),
				  "unsigned char", UCHAR_MAX));
}
%}

%fragment("SWIG_AsUnsignedShort","header",
	  fragment="SWIG_CheckUnsignedLongInRange",
	  fragment="SWIG_AsUnsignedLong") %{
SWIGSTATICINLINE(unsigned short )
SWIG_AsUnsignedShort(PyObject *obj)
{ 
  return swig_numeric_cast(unsigned short,
    SWIG_CheckUnsignedLongInRange(SWIG_AsUnsignedLong(obj),
				  "unsigned short", USHRT_MAX));
}
%}


%fragment("SWIG_FloatCast","header") %{
#include <float.h>

SWIGSTATIC(float)
SWIG_FloatCast(double value)
{
  float f = 0;
  if (!PyErr_Occurred()) {
    if (value < FLT_MIN) {
      PyObject *err = 
        PyString_FromFormat("value %g is less than float minimum %g", 
			    value, FLT_MIN);
      PyErr_SetObject(PyExc_OverflowError, err);
      Py_DECREF(err);
    } else if (value > FLT_MAX) {
      PyObject *err = 
        PyString_FromFormat("value %g is greater than float maximum %g", 
			    value, FLT_MAX);
      PyErr_SetObject(PyExc_OverflowError, err);
      Py_DECREF(err);
    } else {
      f = swig_numeric_cast(float, value);
    }
  }
  return f;
}
%}

%fragment("SWIG_AsFloat","header",
	  fragment="SWIG_FloatCast",
	  fragment="SWIG_AsDouble") %{
SWIGSTATICINLINE(float)
SWIG_AsFloat(PyObject *obj)
{
  return SWIG_FloatCast(SWIG_AsDouble(obj));
}
%}

%fragment("SWIG_FromChar","header") %{
SWIGSTATICINLINE(PyObject*)
SWIG_FromChar(char c) 
{ 
  return PyString_FromStringAndSize(&c,1);
}
%}

%fragment("SWIG_FromBool","header") %{
SWIGSTATICINLINE(PyObject*)
SWIG_FromBool(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
%}

%fragment("SWIG_AsBool","header") %{
SWIGSTATICINLINE(bool)
SWIG_AsBool(PyObject *obj)
{
  return PyObject_IsTrue(obj) ? true : false;
}
%}

%fragment("SWIG_AsChar","header",
	  fragment="SWIG_AsCharArray",
	  fragment="SWIG_CheckLongInRange",
	  fragment="SWIG_AsLong") %{
SWIGSTATICINLINE(char)
SWIG_AsChar(PyObject *obj)
{ 
  char c = 0;
  if (PyInt_Check(obj) || PyLong_Check(obj)) {
    c = swig_numeric_cast(char,
      SWIG_CheckLongInRange(SWIG_AsLong(obj),
			    "char", CHAR_MIN, CHAR_MAX));
  } else {  
    SWIG_AsCharArray(obj, &c, 1);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      PyErr_SetString(PyExc_TypeError, "a char is expected");
    }
  }
  return c;
}
%}

%typemap_stype(bool,               BOOL,    Bool);
%typemap_stype(signed char,        INT8,    SignedChar);
%typemap_stype(unsigned char,      UINT8,   UnsignedChar);
%typemap_stype(short,              INT16,   Short);
%typemap_stype(unsigned short,     UINT16,  UnsignedShort);
%typemap_stype(int,                INT32,   Int);
%typemap_stype(unsigned int,       UINT32,  UnsignedInt);
%typemap_stype(long,               INT64,   Long);
%typemap_stype(unsigned long,      UINT64,  UnsignedLong);
%typemap_stype(long long,          INT128,  LongLong);
%typemap_stype(unsigned long long, UINT128, UnsignedLongLong);
%typemap_stype(float,              FLOAT,   Float);
%typemap_stype(double,             DOUBLE,  Double);
%typemap_stype(char,               CHAR,    Char);
