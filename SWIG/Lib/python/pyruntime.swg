/* Python.h has to appear first */
%insert(runtime) %{
#include <Python.h>
%}

%insert(runtime) "swigrun.swg";         /* Common C API type-checking code */
%insert(runtime) "pyapi.swg";           /* SWIG/Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */


/* When using -nortti, tell directors to avoid RTTI */
#ifdef SWIG_NORTTI
%insert("runtime") %{
#ifndef SWIG_DIRECTOR_NORTTI
#define SWIG_DIRECTOR_NORTTI
#endif
%}
#endif
