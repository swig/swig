%module preproc_include

%{
#include "preproc_include_a.h"
#include "preproc_include_b.h"
int multiply10(int a) { return a*10; }
int multiply20(int a) { return a*20; }
int multiply30(int a) { return a*30; }
int multiply40(int a) { return a*40; }
int multiply50(int a) { return a*50; }
%}

#define INCLUDE_B preproc_include_b.h
#define FILE_INCLUDE(FNAME) #FNAME

%include FILE_INCLUDE(preproc_include_a.h)

// Note that this test uses -includeall, so including preproc_include_b.h also includes preproc_include_c.h
%include INCLUDE_B

%include"preproc_include_d withspace.h"

#define INCLUDE_E "preproc_include_e withspace.h"

%include INCLUDE_E

%inline %{
#define INCLUDE_F /*comments*/ "preproc_include_f withspace.h"/*testing*/
#include INCLUDE_F
#include /*oooo*/"preproc_include_g.h"/*ahhh*/
%}

%{
int multiply60(int a) { return a*60; }
int multiply70(int a) { return a*70; }
%}

