/* SWIG Configuration File for Guile. 
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "guiledec.swg"

#ifndef SWIG_NOINCLUDE
%insert(runtime) "guile.swg"
#endif

/* Read in standard typemaps. */
%include "typemaps.i"

