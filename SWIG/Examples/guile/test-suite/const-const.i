/* This interface file tests whether SWIG handles types like
   "const int *const" right.

   SWIG 1.3a5 signals a syntax error.
*/

%typemap(in) const int *const { $target = NULL; }

%inline %{
void foo(const int *const i) {}
%}
