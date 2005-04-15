/* This is a basic test of proxy classes, used by chicken */

%module cpp_basic

%newobject Bar::testFoo;

%inline %{

class Foo {
  public:
    Foo(int a) : num(a) {}
    int num;
};

%}

%{
static Foo init_ref = Foo(-4);
%}

%inline %{
class Bar {
  public:
    Bar() : fptr(0), fref(init_ref), fval(15) , cint(3) {}
  
    Foo *fptr;
    Foo &fref;
    Foo fval;

    const int cint;
    static const int global_cint = -4;

    static Foo *global_fptr;
    static Foo &global_fref;
    static Foo global_fval;

    int test(int a, Foo *f) {
      return a + (f ? f->num : 0) + fval.num;
    }

    Foo *testFoo(int a, Foo *f) {
      return new Foo(2 * a + (f ? f->num : 0) + fval.num);
    }
};

%}

%{
Foo *Bar::global_fptr = NULL;
Foo &Bar::global_fref = init_ref;
Foo Bar::global_fval = Foo(3);
%}
