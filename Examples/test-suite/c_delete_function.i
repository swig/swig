%module c_delete_function

/* check C++ delete keyword is okay in C wrappers */

%warnfilter(SWIGWARN_PARSE_KEYWORD) delete;

/* Octave, Javascript/v8 and Objective-C compile wrappers as C++. */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI) && !defined(SWIGOBJECTIVEC)

%inline %{
double delete(double d) { return d; }
%}

#endif
