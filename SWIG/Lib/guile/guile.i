/* SWIG Configuration File for Guile. -*-c-*-
   This file is parsed by SWIG before reading any other interface
   file. */

/* Include headers */
%insert(runtime) "guiledec.swg"

#ifndef SWIG_NOINCLUDE
%insert(runtime) "guile.swg"
#endif

%insert(runtime) %{
#ifdef __cplusplus
template<class T> class SwigValueWrapper {
    T* tt;
public:
    SwigValueWrapper() : tt(0) {}
    SwigValueWrapper& operator=(T& t) {tt = &t; return *this;}
    operator T() const {return *tt;};
};                                                    
#endif
%}

#define %scheme	    %insert("scheme")

#define %values_as_list   %pragma(guile) beforereturn = ""
#define %values_as_vector %pragma(guile) beforereturn = "GUILE_MAYBE_VECTOR"
#define %multiple_values  %pragma(guile) beforereturn = "GUILE_MAYBE_VALUES"

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
