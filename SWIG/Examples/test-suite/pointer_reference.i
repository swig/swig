/* This interface file tests whether SWIG handles pointer-reference
   (*&) arguments.

   SWIG 1.3a5 signals a syntax error.
*/

%module pointer_reference

#ifdef SWIGGUILE
/* A silly testing typemap for feeding a doubly indirect integer */
%typemap(in) int *&XYZZY (int temp1, int *temp2) {
   temp1 = gh_scm2int($input); temp2 = &temp1; $1 = &temp2;
};
#endif

%inline %{
void foo(int *&XYZZY) {}
%}
