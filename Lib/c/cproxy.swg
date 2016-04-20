/* -----------------------------------------------------------------------------
 * cproxy.swg
 *
 * Definitions of C specific preprocessor symbols for proxies.
 * ----------------------------------------------------------------------------- */

#ifndef SWIGIMPORT
# ifndef __GNUC__
#   define __DLL_IMPORT __declspec(dllimport)
# else
#   define __DLL_IMPORT __attribute__((dllimport)) extern
# endif
# if !defined (__WIN32__)
#   define SWIGIMPORT extern
# else
#   define SWIGIMPORT __DLL_IMPORT
# endif
#endif

#include <stddef.h>
