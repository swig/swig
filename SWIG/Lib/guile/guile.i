/* SWIG Configuration File for Guile. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "guiledec.swg"

#ifndef SWIG_NOINCLUDE
%insert(runtime) "guile.swg"
#endif

/* Macro for inserting Scheme code into the stub */
#define %scheme	    %insert("scheme")

/* Return-styles */
%pragma(guile) return_nothing_doc = "Returns unspecified."
%pragma(guile) return_one_doc = "Returns $values."

%define %values_as_list
  %pragma(guile) beforereturn = ""
  %pragma(guile) return_multi_doc = "Returns a list of $num_values values: $values."
%enddef
%values_as_list /* the default style */

%define %values_as_vector
  %pragma(guile) beforereturn = "GUILE_MAYBE_VECTOR"
  %pragma(guile) return_multi_doc = "Returns a vector of $num_values values: $values."
%enddef

%define %multiple_values
  %pragma(guile) beforereturn = "GUILE_MAYBE_VALUES"
  %pragma(guile) return_multi_doc = "Returns $num_values values: $values."
%enddef

/* The following definitions are supposed to provide a common API for
   the supported Scheme dialects, so that typemaps may be shared.  I
   also plan to adopt Guile's high-level interface (GH) for this
   purpose. */
#define SWIG_malloc(size) \
  SCM_MUST_MALLOC(size)
#define SWIG_free(mem) \
  scm_must_free(mem)
#define SWIG_GetPtr(s, result, type) \
  SWIG_Guile_GetPtr(s, result, type)
#define SWIG_MustGetPtr(s, type, argnum) \
  SWIG_Guile_MustGetPtr(s, type, argnum, FUNC_NAME)
#define SWIG_MakePtr(ptr, type) \
  SWIG_Guile_MakePtr(ptr, type)

/* Read in standard typemaps. */
%include "typemaps.i"
