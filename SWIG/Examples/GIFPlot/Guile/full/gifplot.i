/* Oh what the heck, let's just grab the whole darn header file
   and see what happens. */

%module gifplot
%{

/* Note: You still need this part because the %include directive
   merely causes SWIG to interpret the contents of a file.  It doesn't
   include the right include headers for the resulting C code */

#include "gifplot.h"

%}

/* Pixel is typedef'd to unsigned char, and SWIG will translate this
   type into Scheme characters. We would like to translate Pixels to
   Scheme integers instead, so: */

SIMPLE_MAP(Pixel, gh_scm2int, gh_int2scm, integer);

%include gifplot.h
