/* SWIG Configuration File for MzScheme. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "mzschemedec.swg"

/*#ifndef SWIG_NOINCLUDE*/
%insert(runtime) "mzscheme.swg"
/*#endif*/

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

