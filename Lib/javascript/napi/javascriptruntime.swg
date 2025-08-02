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

// This gives us
// Branch Node.js v10.x - from v10.20.0
// Branch Node.js v12.x - from v12.17.0
// Everything from Node.js v14.0.0 on
// Our limiting feature is napi_set_instance_data
#ifndef NAPI_VERSION
#define NAPI_VERSION 6
#elif NAPI_VERSION < 6
#error NAPI_VERSION 6 is the minimum supported target (Node.js >=14, >=12.17, >=10.20)
#endif
#include <napi.h>

#include <limits.h>
#include <stdlib.h>
#include <assert.h>
#include <map>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg"

