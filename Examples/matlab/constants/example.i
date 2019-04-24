/* File : example.i */
%module example

%{
#include <complex>
%}

%include std_complex.i

/* A few preprocessor macros */

#define    ICONST      42
#define    FCONST      2.1828
#define    CCONST      'x'
#define    CCONST2     '\n'
#define    SCONST      "Hello World"
#define    SCONST2     "\"Hello World\""

/* This should work just fine */
#define    EXPR        ICONST + 3*(FCONST)

/* This shouldn't do anything */
#define    EXTERN      extern

/* Neither should this (BAR isn't defined) */
#define    FOO         (ICONST + BAR)

/* The following directives also produce constants */

%constant int iconst3 = 37;
%constant double fconst3 = 3.14;
/* The following line is commented because of this warning message in SWIG 4.0.0: example.i:32: Warning 305: Bad constant value (ignored). */
/*%constant std::complex<double> cxconst(3.14,-3); */
