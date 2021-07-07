/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * ----------------------------------------------------------------------------- */

// V8 Version Macro
// ----------------
//
// v8 added version macros V8_MAJOR_VERSION, V8_MINOR_VERSION, V8_BUILD_NUMBER
// and V8_PATCH_LEVEL in version 4.3.0.  SWIG generated code uses these if
// they are defined - to support earlier versions you can specify the V8 version
// in use via the command line when you run SWIG:
//
//   swig -c++ -javascript -v8 -DV8_VERSION=0x032530 example.i
//
// Or code in the interface file using SWIG_V8_VERSION:
//
//   %begin %{#define SWIG_V8_VERSION 0x031110%}
//
// This is specified as a hex constant, but the constant is read as pairs of
// decimal digits, so for V8 3.25.30 use constant 0x032530.  This scheme can't
// represent components > 99, but this constant is only useful for V8 < 4.3.0,
// and no V8 versions from that era had a component > 99.

%define %swig_v8_define_version(version)
%insert("runtime") %{
#ifndef SWIG_V8_VERSION
#define SWIG_V8_VERSION version
#endif
%}
%enddef

#ifdef V8_VERSION
%swig_v8_define_version(V8_VERSION)
#else
// HACK: defining a default version
%swig_v8_define_version(0x031110)
#endif


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

#if defined(V8_MAJOR_VERSION) && defined(V8_MINOR_VERSION)
#undef SWIG_V8_VERSION
#define SWIG_V8_VERSION (V8_MAJOR_VERSION * 256 + V8_MINOR_VERSION)
#endif

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

