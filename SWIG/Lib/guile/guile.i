/* SWIG Configuration File for Guile. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "guiledec.swg"

#ifndef SWIG_NOINCLUDE
%insert(runtime) "guile.swg"
#endif

#define %scheme	    %insert("scheme")

#define %values_as_list   %pragma(guile) beforereturn ""
#define %values_as_vector %pragma(guile) beforereturn "GUILE_MAYBE_VECTOR"
#define %multiple_values  %pragma(guile) beforereturn "GUILE_MAYBE_VALUES"



/* Read in standard typemaps. */
%include "typemaps.i"

