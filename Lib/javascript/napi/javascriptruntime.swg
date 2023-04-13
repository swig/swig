/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * ----------------------------------------------------------------------------- */

// NAPI
// ----------

%insert(runtime) %{
#define NAPI_CPP_EXCEPTIONS
#include <napi.h>

#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <assert.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg"

