/* SWIG Configuration File for MzScheme. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%runtime "common.swg"
%runtime "mzrun.swg"

%define SWIG_APPEND_VALUE(value)
   values[lenv++] = value
%enddef

/* Definitions */
#define SWIG_malloc(size) swig_malloc(size, FUNC_NAME)
#define SWIG_free(mem) free(mem)

/* Guile compatibility kludges */
#define SCM_VALIDATE_VECTOR(argnum, value) (void)0
#define SCM_VALIDATE_LIST(argnum, value) (void)0

/* Read in standard typemaps. */
%include "typemaps.i"

%init %{
  static int _swig_init = 0;

  if (!_swig_init) {
    int i;
    SWIG_MzScheme_LookupTypePointer(env);
    for (i = 0; swig_types_initial[i]; i++) {
      swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
    _swig_init = 1;
  }
%}
