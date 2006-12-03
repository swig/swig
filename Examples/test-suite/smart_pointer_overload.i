%module smart_pointer_overload

#ifndef SWIG_NO_OVERLOAD

%inline %{
struct Foo {
   int x;
   int test(int y) { y = 0; return 1; }
   int test(double y) { y = 0; return 2; }
   int test(char *s) { s = 0; return 3; }
};

class Bar {
   Foo *f;
public:
   Bar(Foo *f) : f(f) { }
   Foo *operator->() {
      return f;
   }
};
%}

#endif

