/* -----------------------------------------------------------------------------
 * clabels.swg
 *
 * Definitions of C specific preprocessor symbols.
 * ----------------------------------------------------------------------------- */

// this is used instead of default SWIGEXPORT symbol

#ifndef SWIGEXPORTC
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORTC
#   else
#     define SWIGEXPORTC __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORTC __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORTC
#   endif
# endif
#endif
