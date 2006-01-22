/* Python.h has to appear first */
%insert(runtime) %{
#include <Python.h>

/* Add PyOS_snprintf for old Pythons */
#if PY_VERSION_HEX < 0x02020000
#if defined(_MSC_VER) || defined(__BORLANDC__) || defined(_WATCOM)
#  define PyOS_snprintf _snprintf
#else
#  define PyOS_snprintf snprintf
#endif

/* A crude PyString_FromFormat implementation for old Pythons */
#if PY_VERSION_HEX < 0x02020000

#ifndef SWIG_PYBUFFER_SIZE
#define SWIG_PYBUFFER_SIZE 1024
#endif

static PyObject *
PyString_FromFormat(const char *fmt, ...) {
  va_list ap;
  char buf[SWIG_PYBUFFER_SIZE * 2];
  int res;
  va_start(ap, fmt);
  res = vsnprintf(buf, sizeof(buf), fmt, ap);
  va_end(ap);
  return (res < 0 || res >= sizeof(buf)) ? 0 : PyString_FromString(buf);
}
#endif

/* Add PyObject_Del for old Pythons */
#if PY_VERSION_HEX < 0x01060000
#define PyObject_Del(op) PyMem_DEL((op))
#endif
#ifndef PyObject_DEL
#define PyObject_DEL PyObject_Del
#endif

/* A crude PyExc_StopIteration exception for old Pythons */
#if PY_VERSION_HEX < 0x02020000
#define PyExc_StopIteration PyExc_RuntimeError
#define PyObject_GenericGetAttr 0
#define Py_NotImplemented PyExc_RuntimeError
#endif


/* A crude PyString_AsStringAndSize implementation for old Pythons */
#if PY_VERSION_HEX < 0x02010000
#define PyString_AsStringAndSize(obj, s, len) {*s = PyString_AsString(obj); *len = *s ? strlen(*s) : 0;}
#endif

#if PY_VERSION_HEX < 0x02000000
#define PySequence_Size PySequence_Length
#endif

%}
%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg"       /* SWIG errors */   
%insert(runtime) "pythreads.swg";       /* Python thread code */
%insert(runtime) "pyapi.swg";           /* Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */

/* When using -nortti, tell directors to avoid RTTI */
#ifdef SWIG_NORTTI
%insert("runtime") %{
#ifndef SWIG_DIRECTOR_NORTTI
#define SWIG_DIRECTOR_NORTTI
#endif
%}
#endif
