%module preproc_gcc_output
// Testcase for Github issue #1475 using the output of gcc -E

// The file below was generated using 'gcc -E header1.h'
// where header1.h included header2.h
%include "preproc_gcc_output.h"

%{
void header1_function_a(int a) {}
void header2_function(int x) {}
void header1_function_b(int b) {}
%}
