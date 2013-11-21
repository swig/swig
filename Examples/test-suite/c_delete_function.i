%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

#if !defined(SWIGOCTAVE) /* Octave compiles wrappers as C++ */

%inline %{
double delete(double d) { return d; }
%}

#endif
