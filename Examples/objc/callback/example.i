/* File : example.i */

%module(directors="1") example
%rename("OC%s", %$isclass) "";
%{
#include "example.h"
%}

%include "std_string.i"

/* turn on director wrapping Callback */
%feature("director") Callback;

%typemap(in) Callback * ($1_type argp)
%{ argp = new SwigDirector_OC$*1_type();
   ((SwigDirector_OC$*1_type *)argp)->swig_connect_director((__bridge id)$input);
   $1 = argp; %}

%include "example.h"

