%module c_delete

/* check C++ delete keyword is okay in C wrappers */

%warnfilter(SWIGWARN_PARSE_KEYWORD) delete;

/* Octave and Javascript/v8 compiles wrappers as C++ */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI)

%inline %{
struct delete {
  int delete;
};
%}

%rename(DeleteGlobalVariable) delete;
%inline %{
int delete = 0;
%}

#endif
