/* File : example.i */
%module example

%{
#include "example.h"
%}

%typemap(throws, noblock="1") Exc {
  SWIG_exception(SWIG_RuntimeError, $1.msg);
}

/* Let's just grab the original header file here */
%include "example.h"

