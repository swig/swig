%module python_flatstaticmethod

// This testcase tests C++ class static functions when using legacy "flattened"
// staticmethod access, A_bar, as well as the normal staticmethod access, A.bar.

%callback(1) A::bar;
%feature("kwargs") A::pub;
%feature("autodoc","0") A::func0static; // names
%feature("autodoc","1") A::func1static; // names + types
// special typemap and its docs
%typemap(in) (int c, int d) "$1 = 0; $2 = 0;"
%typemap(doc,name="hello",type="Tuple") (int c, int d) "hello: int tuple[2]"

%extend A {
static int staticextended(int i) { return i; }
}

%inline %{
  struct A {
    static int bar(int a) {
      return 2*a;
    }
    static int pub(int a = 1, int b = 0) {
      return a + b;
    }
    static int func0static(A *e, short, int c, int d, double f = 2) { return 0; }
    static int func1static(A *e, short, int c, int d, double f = 2) { return 0; }

    static const char *over(int) { return "over:int"; }
    static const char *over(double) { return "over:double"; }
    static const char *over(char *) { return "over:char *"; }

    static int defargs(int xx = 10, int yy = 20) { return xx + yy; }
  };

  extern "C" int foobar(int a, int (*pf)(int a)) {
    return pf(a);
  }
%}

