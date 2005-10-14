%module typedef_struct

%inline %{
  typedef struct {
    int numpoints;
  } lineObj;
  
  typedef lineObj multipointObj;
  
  typedef struct {
#ifdef SWIG
    %immutable;
#endif
    char *filename; 
    int numfonts;
#ifdef SWIG
    %mutable;
#endif
    int* fonts;
#ifndef SWIG
    void* map;
#endif
  } fontSetObj;

#define MS_NOOVERRIDE -1111

%}
