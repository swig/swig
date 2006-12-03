/* Oh what the heck, let's just grab the whole darn header file
   and see what happens. */

%module gifplot
%{

/* Note: You still need this part because the %include directive
   merely causes SWIG to interpret the contents of a file.  It doesn't
   include the right include headers for the resulting C code */

#include "gifplot.h"

%}

%include gifplot.h
