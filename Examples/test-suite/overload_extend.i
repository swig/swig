%module overload_extend

#pragma SWIG nowarn=-302
%extend Foo {
    int test() { return 0; }
    int test(int x) { x = 0; return 1; }
    int test(char *s) { s = 0; return 2; }
    int test(double x, double y = 0) { x = 0; y = 0; return 3; }
};

%inline %{
struct Foo {
    int test() { return -1; }
};
%}



       

