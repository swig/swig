/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * ----------------------------------------------------------------------------- */

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

#ifdef BUILDING_NODE_EXTENSION
%insert("runtime") %{
#include <node.h>
%}
#endif

%insert(runtime) %{
#include <v8.h>

#include <errno.h>
#include <limits.h>
%}

%insert(runtime) "swigrun.swg";         /* SWIG API */
%insert(runtime) "swigerrors.swg";      /* SWIG errors */

%insert(runtime) "javascriptrun.swg"

