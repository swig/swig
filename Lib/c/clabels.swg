/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * clabels.swg
 *
 * Definitions of some C specific preprocessor symbols.
 * ----------------------------------------------------------------------------- */

// this is used instead of default SWIGEXPORT symbol
#ifndef SWIGEXPORTC
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORTC
#   else
#     define SWIGEXPORTC
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORTC __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORTC
#   endif
# endif
#endif

#ifndef SWIGPROTECT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   define SWIGPROTECT(x)
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGPROTECT(x) __attribute__ ((visibility("protected"))) x
#   else
#     define SWIGPROTECT(x)
#   endif
# endif
#endif

