/*** Matrix and vector example ***/

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

%{
/* Add drand48 declaration as it is posix only and is not in stdlib.h when using strict c99 and later */
extern double drand48(void);
%}
extern double drand48(void);
