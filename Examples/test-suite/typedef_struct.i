%module typedef_struct

%inline %{
  typedef struct {
    int numpoints;
  } LineObj;
  
  typedef LineObj MultipointObj;
  
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
  } FontSetObj;

#define MS_NOOVERRIDE -1111

%}
