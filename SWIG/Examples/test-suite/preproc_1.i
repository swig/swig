/* This interface file tests whether SWIG's extended C
   preprocessor is working right. 

   In this example, SWIG 1.3.6 chokes on "//" in a #define with a
   syntax error.
*/

%module preproc_1

#define SLASHSLASH "//"
