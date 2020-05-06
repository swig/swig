/* File : example.i */
%module(directors="1") example
%{
#include "example.h"
%}

/* turn on director wrapping Callback */
%feature("director") Callback;

%feature("ref")   Interface "$this->Interface::AddRef();"
%feature("unref") Interface "$this->Interface::Release();"

%include "example.h"

