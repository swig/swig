%module c_delete

/* check C++ delete and new keywords are okay in C wrappers */

%warnfilter(SWIGWARN_PARSE_KEYWORD) delete;
%warnfilter(SWIGWARN_PARSE_KEYWORD) new;

/* Octave and Javascript/v8 compiles wrappers as C++ */
#if !defined(SWIGOCTAVE) && !defined(SWIG_JAVASCRIPT_V8) && !defined(SWIG_JAVASCRIPT_NAPI)

%inline %{
struct delete {
  int delete;
  int new;
};
%}

%rename(DeleteGlobalVariable) delete;
%inline %{
int delete = 0;
%}

%rename(NewFunction) new(int);
%inline %{
int new(int new) { return new + 1; }
%}

#endif
