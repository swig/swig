/* Python.h has to appear first */

%insert(runtime) %{
#include <Python.h>
%}

%insert(runtime) "precommon.swg";
%insert(runtime) %{

#ifndef SWIG_ALLOW_RUNTIME
/* -----------------------------------------------------------------------------
 * Disable runtime library use, everything is used as static
 * ----------------------------------------------------------------------------- */
#ifndef SWIG_DISABLE_RUNTIME
#define SWIG_DISABLE_RUNTIME
#endif
#ifdef SWIG_GLOBAL
#undef SWIG_GLOBAL
#endif
#ifdef SWIG_NOINCLUDE
#undef SWIG_NOINCLUDE
#endif
#endif /* SWIG_ALLOW_RUNTIME */

%}
%insert(runtime) "common.swg";          /* Common type-checking code */
%insert(runtime) "pyapi.swg";           /* SWIG/Pyton API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */
