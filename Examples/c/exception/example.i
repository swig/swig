/* File : example.i */
%module example

%{
#include "example.h"
%}

%typemap(throws, noblock="1") Exc {
  SWIG_exception(SWIG_RuntimeError, $1.msg);
}

/* This needs to be defined for SWIG, even though it can't be used in C++ any more. */
#define SWIG_THROW(...) throw(__VA_ARGS__)

/* Let's just grab the original header file here */
%include "example.h"

