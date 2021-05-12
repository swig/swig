/* File : example.i */
/* module name given on cmdline */

%feature("autodoc", 1);

%{
#include "example.h"
%}

%include "example.h"
