/* File : example.i */
%module example

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

%constant int iconst = 37;
%constant double fconst = 3.14;

/* Now constants are wrapped to Scilab variables */
%scilabconst(1);

#define    ICONST2      12
#define    FCONST2      4.60
#define    CCONST3      'a'
#define    CCONST4     '\n'
#define    SCONST3      "Hello World"
#define    SCONST4     "\"Hello World\""

%constant int iconst2 = 73;
%constant double fconst2 = 6.28;


