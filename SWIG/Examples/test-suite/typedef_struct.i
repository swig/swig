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


%inline %{
typedef struct {
    int a;
    int b;
} a_t, *b_t;

a_t* make_a() {
    return (a_t*)malloc(sizeof(a_t));
}; 

b_t make_b() {
    return make_a();
}; 
%} 
