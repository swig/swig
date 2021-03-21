/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * ----------------------------------------------------------------------------- */

// V8 Version Macro
// ----------------
//
// v8 added version macros V8_MAJOR_VERSION, V8_MINOR_VERSION, V8_BUILD_NUMBER
// and V8_PATCH_LEVEL in version 4.3.0.  SWIG doesn't support anything that
// old so SWIG generated code can rely on these.

// Node support
// ------------

#ifdef BUILDING_NODE_EXTENSION
%insert("runtime") %{
#if defined(__GNUC__)
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wunused-parameter"
// Minimum supported Node.js version is v6.0, which is guaranteed
// to have v8-version.h...
# include <v8-version.h>
# if __GNUC__>=8 && V8_MAJOR_VERSION<7
#  pragma GCC diagnostic ignored "-Wcast-function-type"
# endif
#endif

#include <node.h>
//Older version of node.h does not include this
#include <node_version.h>
%}
#else
%insert("runtime") %{
#if defined(__GNUC__)
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Wunused-parameter"
# if __GNUC__>=8
// Best would be to first include <v8-version.h> and make this #pragma
// dependent even on V8_MAJOR_VERSION, but v8-version.h is not available
// with legacy V8 versions :-(
#  pragma GCC diagnostic ignored "-Wcast-function-type"
# endif
#endif
%}
#endif


// V8 runtime
// ----------

%insert(runtime) %{
#include <v8.h>

#if defined(__GNUC__)
# pragma GCC diagnostic pop
#endif

#undef SWIG_V8_VERSION
#define SWIG_V8_VERSION ((V8_MAJOR_VERSION / 10) * 4096 + \
                         (V8_MAJOR_VERSION % 10) * 256 + \
                         (V8_MINOR_VERSION / 10) * 16 + \
                         (V8_MINOR_VERSION % 10))

#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <assert.h>

class SWIGV8_ClientData;
#define SWIG_CLIENT_DATA_TYPE SWIGV8_ClientData
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg"

