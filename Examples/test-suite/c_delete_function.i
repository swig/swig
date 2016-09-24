%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

%warnfilter(SWIGWARN_PARSE_KEYWORD) delete;

#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_DUK) /* Octave, Javascript/v8 and Javascript/duk compiles wrappers as C++ */

%inline %{
double delete(double d) { return d; }
%}

#endif
