/* Python.h has to appear first */
%insert(runtime) %{
#include <Python.h>

/* Add PyOS_snprintf for old Pythons */
#if PY_VERSION_HEX < 0x02020000
#define PyOS_snprintf snprintf
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
