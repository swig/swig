%module overload_extend

#pragma SWIG nowarn=-302
%extend Foo {
    int test() { return 0; }
    int test(int x) { x = 0; return 1; }
    int test(char *s) { s = 0; return 2; }
#ifdef __cplusplus
    int test(double x, double y = 0) { x = 0; y = 0; return 3; }
#else
    int test(double x, double y) { x = 0; y = 0; return 3; }
#endif
};


%inline %{
struct Foo {
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
} Bar;
%}
       

