/* -----------------------------------------------------------------------------
 * cheader.swg
 * ----------------------------------------------------------------------------- */

%insert("cheader") %{
#ifndef SWIGIMPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGDLLIMPORT
#   else
#     define SWIGDLLIMPORT __declspec(dllimport)
#   endif
# else
#   define SWIGDLLIMPORT
# endif
# define SWIGIMPORT extern SWIGDLLIMPORT
#endif

#include <stddef.h>
%}
