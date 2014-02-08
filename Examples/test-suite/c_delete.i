%module c_delete

/* check C++ delete keyword is okay in C wrappers */

#pragma SWIG nowarn=SWIGWARN_PARSE_KEYWORD

#if !defined(SWIGOCTAVE) /* Octave compiles wrappers as C++ */

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
