// FILE : package.i
// See the SWIG users manual

/*** Matrix and vector package ***/

%module Matrix
%{
#include <math.h>
%}

%include guilemain.i
%include matrix.i
%include vector.i

// Include the math library so we can get some random numbers and
// other stuff

%include math.i

extern double drand48();
