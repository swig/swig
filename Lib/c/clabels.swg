/* -----------------------------------------------------------------------------
 * clabels.swg
 *
 * Definitions of C specific preprocessor symbols.
 * ----------------------------------------------------------------------------- */

// this is used instead of default SWIGEXPORT symbol

#ifndef SWIGEXPORTC
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__) || defined(__APPLE__)
#   define SWIGEXPORTC
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORTC __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORTC
#   endif
# endif
#endif

#ifndef SWIGPROTECT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__) || defined(__APPLE__)
#   define SWIGPROTECT(x)
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGPROTECT(x) __attribute__ ((visibility("protected"))) x
#   else
#     define SWIGPROTECT(x)
#   endif
# endif
#endif

