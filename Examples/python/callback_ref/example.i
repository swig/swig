/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

/* turn on director wrapping Callback */
%feature("director") Callback;

%feature("ref")   Interface "$this->AddRef();"
%feature("unref") Interface "$this->Release();"

%include "example.h"

