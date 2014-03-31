%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) /* Octave and Javascript/v8 compiles wrappers as C++ */

%inline %{
double delete(double d) { return d; }
%}

#endif
