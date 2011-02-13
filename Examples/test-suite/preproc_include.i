%module preproc_include

%{
#include "preproc_include_a.h"
#include "preproc_include_b.h"
int multiply10(int a) { return a*10; }
int multiply20(int a) { return a*20; }
int multiply30(int a) { return a*30; }
%}

#define INCLUDE_B preproc_include_b.h
#define FILE_INCLUDE(FNAME) #FNAME

%include FILE_INCLUDE(preproc_include_a.h)

// Note that this test uses -includeall, so including preproc_include_b.h also includes preproc_include_c.h
%include INCLUDE_B

