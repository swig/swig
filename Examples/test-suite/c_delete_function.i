%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

%warnfilter(SWIGWARN_PARSE_KEYWORD) delete;

/* Octave and Javascript/v8 compiles wrappers as C++ */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI)

%inline %{
double delete(double d) { return d; }
%}

#endif
