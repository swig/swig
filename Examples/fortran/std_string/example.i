/* File : example.i */
%module example

%{
#include "example.h"
%}

// Support native string conversions
%include <std_string.i>

// Demonstrate using a typemap to treat a mutable string as reference
%apply const std::string & { std::string& };

%include "example.h"



