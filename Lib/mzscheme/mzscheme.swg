/* SWIG Configuration File for MzScheme. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

%runtime %{
#define SWIG_malloc(size) SWIG_Mzscheme_Malloc(size, FUNC_NAME)
#define SWIG_free(mem) free(mem)
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_Mzscheme_ConvertPtr(s, result, type, flags)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_Mzscheme_MustGetPtr(s, type, argnum, flags, FUNC_NAME, argc, argv)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_Mzscheme_NewPointerObj((void *)ptr, type, owner)
%}

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
    for (i = 0; swig_types_initial[i]; i++) {
      swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
    _swig_init = 1;
  }
  SWIG_Mzscheme_Init();
%}
