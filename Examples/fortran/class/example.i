/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Replace double-precision with single in Fortran wrapper */
%apply float { double };

/* Enable C-string wrapping */
%include <cstring.i>
%apply const char* NATIVE { const char* };

/* Enable exceptions */
%include <std_except.i>
%exception {
    try {
        $action
    } catch (const std::exception& e) {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

/* Let's just grab the original header file here */
%include "example.h"

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
