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

SIMPLE_TYPEMAP(Pixel, C_unfix, C_fix, C_swig_is_fixnum, (int), 0);

%{
static Pixel int_to_Pixel (int v) { return (Pixel) v; }
%}
extern Pixel int_to_Pixel (int v);

%include gifplot.h
