/* File : example.i */
%module example

#ifndef SWIG_JAVASCRIPT_NAPI
#error This example is specific to the Node-API engine
#endif

%feature("async", "Async");
%feature("sync", "Sync");

%{
#include "example.h"
%}


// A full set of async-compatible maps that handle
// returning a double value in a pointer or reference argument
%typemap(in, numinputs=0) double *result (double temp), double &result (double temp) {
  $1 = &temp;
}
%typemap(argout, fragment=SWIG_From_frag(double)) double *result, double &result {
  $result = SWIG_AppendOutput($result, SWIG_From(double)(*$1));
}
// This variable is always local and does not need locking
%typemap(async_in) double *, double & {}
%typemap(async_pre) double *, double & {}
%typemap(async_post) double *, double & {}

// An example for a hand-written async wrapper with %native
%include "native_async.i"

/* Let's just grab the original header file here */
%include "example.h"
