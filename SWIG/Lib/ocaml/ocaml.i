/* SWIG Configuration File for Ocaml. -*-c-*-
   Modified from mzscheme.i
   This file is parsed by SWIG before reading any other interface
   file. */

/* Insert ML/MLI Common stuff */
%insert(mli) "mliheading.swg"
%insert(ml) "mlheading.swg"

/* Insert common stuff */
%insert(runtime) "common.swg"

/* Include headers */
%insert(runtime) "ocamldec.swg"

/*#ifndef SWIG_NOINCLUDE*/
%insert(runtime) "ocaml.swg"
/*#endif*/

/* Definitions */
#define SWIG_malloc(size) swig_malloc(size, FUNC_NAME)
#define SWIG_free(mem) free(mem)

/* Read in standard typemaps. */
%include "swig.swg"
%include "typemaps.i"
%include "typecheck.i"
%include "exception.i"
