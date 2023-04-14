/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * ----------------------------------------------------------------------------- */

// NAPI
// ----------

%insert(runtime) %{
#if defined(_CPPUNWIND) || defined(__EXCEPTIONS)
#define NAPI_CPP_EXCEPTIONS
#else
#define NAPI_DISABLE_CPP_EXCEPTIONS
#define NODE_ADDON_API_ENABLE_MAYBE
#endif
#include <napi.h>

#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <assert.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg"

