%module preproc_predefined

/* Test that SWIG_VERSION is defined at SWIG-time and in the wrapper. */
#ifndef SWIG_VERSION
# error SWIG_VERSION not defined at SWIG-time
#endif
%{
#ifndef SWIG_VERSION
# error SWIG_VERSION not defined in the generated wrapper
#endif
%}

/* Test that SWIGVERSION is NOT defined at SWIG-time or in the wrapper.
 * It used to be defined in the wrapper as a side-effect of how SWIG_VERSION
 * was defined in the wrapper but was never documented and is redundant.
 */
#ifdef SWIGVERSION
# error SWIGVERSION should not be defined at SWIG-time
#endif
%{
#ifdef SWIGVERSION
# error SWIGVERSION should not be defined in the generated wrapper
#endif
%}

/* Test that SWIG is defined at SWIG-time but not in the wrapper. */
#ifndef SWIG
# error SWIG not defined at SWIG-time
#endif
%{
#ifdef SWIG
# error SWIG should not be defined in the generated wrapper
#endif
%}

/* Test that SWIGxxx is defined at SWIG-time and in the wrapper. */
%include "preproc_predefined.h"
%{
#include "preproc_predefined.h"
%}
