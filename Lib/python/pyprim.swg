#ifndef __python_pyprim_swg__
#define __python_pyprim_swg__

/*
  Define the SWIG_PyObjAs/From methods for the basic types.  In many
  cases, these method are just aliases of the original python As/From
  methods. In the other cases, some extra work is needed.
*/

%{
#include <limits.h>
#include <float.h>
#include <string.h>

#ifndef SWIGSTATIC
#ifdef __cplusplus
#define SWIGSTATIC(a) static inline a
#else
#define SWIGSTATIC(a) static a
#endif
#endif

#ifndef numeric_cast
#ifdef __cplusplus
#ifdef HAVE_NUMERIC_CAST
#define numeric_cast(type,a) numeric_cast<type>(a)
#else
#define numeric_cast(type,a) static_cast<type>(a)
#endif
#else
#define numeric_cast(type,a) (type)(a)
#endif
#endif

%}

/*
  no wrapped found needed here... yet,
  and we define the names  SWIG_PyObj for consistency
 */ 

%{
#define SWIG_PyObj_FromSignedChar     PyInt_FromLong
#define SWIG_PyObj_FromUnsignedChar   PyInt_FromLong
#define SWIG_PyObj_FromShort         PyInt_FromLong
#define SWIG_PyObj_FromUnsignedShort  PyInt_FromLong
#define SWIG_PyObj_FromInt           PyInt_FromLong
#define SWIG_PyObj_FromLong          PyInt_FromLong
#define SWIG_PyObj_FromFloat         PyFloat_FromDouble
#define SWIG_PyObj_FromDouble        PyFloat_FromDouble
#define SWIG_PyObj_FromFloat         PyFloat_FromDouble
#define SWIG_PyObj_FromDouble        PyFloat_FromDouble
%}

%fragment("SWIG_PyObj_AsDouble","header") %{
SWIGSTATIC(double)
SWIG_PyObj_AsDouble(PyObject *obj)
{
  return (PyFloat_Check(obj)) ? PyFloat_AsDouble(obj) :
#if HAVE_LONG_LONG
    (double)((PyInt_Check(obj)) ? PyInt_AsLong(obj) : PyLong_AsLongLong(obj));
#else
    (double)((PyInt_Check(obj)) ? PyInt_AsLong(obj) : PyLong_AsLong(obj));
#endif
  if (PyErr_Occurred()) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError, "a double is expected");
  }
}
%}


%fragment("SWIG_PyObj_AsLong","header") %{
SWIGSTATIC(long)
SWIG_PyObj_AsLong(PyObject * obj)
{
  return PyInt_Check(obj) ? PyInt_AsLong(obj) : PyLong_AsLong(obj);
}
%}


%fragment("SWIG_PyObj_FromLongLong","header") %{
SWIGSTATIC(PyObject* )
SWIG_PyObj_FromLongLong(long long value)
{
  return (value > (long long)(LONG_MAX)) ?
    PyLong_FromLongLong(value) : PyInt_FromLong((long)value); 
}
%}

%fragment("SWIG_PyObj_FromUnsignedLongLong","header") %{
SWIGSTATIC(PyObject* )
SWIG_PyObj_FromUnsignedLongLong(unsigned long long value)
{
  return (value > (unsigned long long)(LONG_MAX)) ?
    PyLong_FromUnsignedLongLong(value) : 
    PyInt_FromLong(numeric_cast(long, value)); 
}
%}

%fragment("SWIG_PyObj_AsLongLong","header") %{
SWIGSTATIC(long long)
SWIG_PyObj_AsLongLong(PyObject *obj)
{
  return PyInt_Check(obj) ? PyInt_AsLong(obj) : PyLong_AsLongLong(obj);
}
%}

%fragment("SWIG_PyObj_AsUnsignedLongLong","header",
	  fragment="SWIG_PyObj_AsUnsignedLong") %{
SWIGSTATIC(unsigned long long)
SWIG_PyObj_AsUnsignedLongLong(PyObject *obj)
{
  return PyLong_Check(obj) ?
    PyLong_AsUnsignedLongLong(obj) : SWIG_PyObj_AsUnsignedLong(obj);
}
%}


%fragment("SWIG_PyObj_FromUnsignedLong","header") %{
SWIGSTATIC(PyObject* )
SWIG_PyObj_FromUnsignedLong(unsigned long value)
{
  return (value > (unsigned long)(LONG_MAX)) ?
    PyLong_FromUnsignedLong(value) : PyInt_FromLong((long)value); 
}
%}

%fragment("SWIG_PyObj_AsSignedChar","header") %{
SWIGSTATIC(signed char)
SWIG_PyObj_AsSignedChar(PyObject *obj)
{ 
  return numeric_cast(signed char,
    SWIG_PyObj_AsLongInRange(obj, "signed char", SCHAR_MIN, SCHAR_MAX));
}
%}

%fragment("SWIG_PyObj_AsShort","header") %{
SWIGSTATIC(short)
SWIG_PyObj_AsShort(PyObject *obj)
{ 
  return numeric_cast(short,
    SWIG_PyObj_AsLongInRange(obj, "short", SHRT_MIN, SHRT_MAX));
}
%}

%fragment("SWIG_PyObj_AsInt","header") %{
SWIGSTATIC(int)
SWIG_PyObj_AsInt(PyObject *obj)
{ 
  return numeric_cast(int,
    SWIG_PyObj_AsLongInRange(obj, "int", INT_MIN, INT_MAX));
}
%}

%fragment("SWIG_PyObj_AsUnsignedChar","header") %{
SWIGSTATIC(unsigned char)
SWIG_PyObj_AsUnsignedChar(PyObject *obj)
{ 
  return numeric_cast(unsigned char,
    SWIG_PyObj_AsUnsignedLongInRange(obj, "unsigned char", UCHAR_MAX));
}
%}

%fragment("SWIG_PyObj_AsUnsignedShort","header") %{
SWIGSTATIC(unsigned short )
SWIG_PyObj_AsUnsignedShort(PyObject *obj)
{ 
  return numeric_cast(unsigned short,
    SWIG_PyObj_AsUnsignedLongInRange(obj, "unsigned short", USHRT_MAX));
}
%}

%fragment("SWIG_PyObj_AsUnsignedInt","header") %{
SWIGSTATIC(unsigned int)
SWIG_PyObj_AsUnsignedInt(PyObject *obj)
{ 
  return numeric_cast(unsigned int,
    SWIG_PyObj_AsUnsignedLongInRange(obj, "unsigned int", UINT_MAX));
}
%}

%fragment("SWIG_PyObj_AsFloat","header",
	  fragment="SWIG_PyObj_AsDouble") %{
SWIGSTATIC(float)
SWIG_PyObj_AsFloat(PyObject *obj)
{
  return SWIG_PyObj_AsFloatConv(obj, SWIG_PyObj_AsDouble);
}
%}

%fragment("SWIG_PyObj_FromChar","header") %{
SWIGSTATIC(PyObject*)
SWIG_PyObj_FromChar(char c) 
{ 
  return PyString_FromStringAndSize(&c,1);
}
%}

%fragment("SWIG_PyObj_FromBool","header") %{
SWIGSTATIC(PyObject*)
SWIG_PyObj_FromBool(bool value)
{
  PyObject *obj = value ? Py_True : Py_False;
  Py_INCREF(obj);
  return obj;
}
%}

%fragment("SWIG_PyObj_AsBool","header") %{
SWIGSTATIC(bool)
SWIG_PyObj_AsBool(PyObject *obj)
{
  return PyObject_IsTrue(obj) ? true : false;
}
%}

%fragment("SWIG_PyObj_AsChar","header" ) %{
SWIGSTATIC(char)
SWIG_PyObj_AsChar(PyObject *obj)
{ 
  char c = 0;
  if (PyInt_Check(obj) || PyLong_Check(obj)) {
    c = numeric_cast(char,
          SWIG_PyObj_AsLongInRange(obj, "char",CHAR_MIN, CHAR_MAX));
  } else {  
    char* cptr; size_t csize;
    SWIG_PyObj_AsCharPtrAndSize(obj, 0, &cptr, &csize);
    if (csize == 1) {
      c = cptr[0];
    } else {
      PyErr_SetString(PyExc_TypeError, "a char is expected");
    }
  }
  return c;
}
%}

%fragment("SWIG_PyObj_FromUnsignedInt","header",
	  fragment="SWIG_PyObj_FromUnsignedLong") %{
#define SWIG_PyObj_FromUnsignedInt    SWIG_PyObj_FromUnsignedLong  
%}

#endif //__python_pyprim_swg__
