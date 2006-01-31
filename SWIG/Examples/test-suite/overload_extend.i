%module overload_extend

#ifndef __cplusplus
%{
#include <stdlib.h>
%}

%typemap(default) double y "$1=1000;";
#endif

%warnfilter(SWIGWARN_PARSE_REDEFINED) Foo::test; 



%extend Foo {
    int test() { return 0; }
    int test(int x) { x = 0; return 1; }
    int test(char *s) { s = 0; return 2; }
#ifdef __cplusplus
    double test(double x, double y = 1000) { return x + y; }
#else
    double test(double x, double y) { return x + y; }
#endif
};


%inline %{
struct Foo {
  int variable;
#ifdef __cplusplus
    int test() { return -1; }
#endif
};
%}


%extend Bar {
#ifdef __cplusplus
  Bar() {
    return new Bar();
  }
  ~Bar() {
    if (self) delete self;
  }
#else
  Bar() {
    return (Bar *) malloc(sizeof(Bar));
  }
  ~Bar() {
    if (self) free(self);
  }
#endif
}

%inline %{
typedef struct {
  int variable;
} Bar;
%}
       

