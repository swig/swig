%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

%inline %{
double delete(double d) { return d; }
%}
