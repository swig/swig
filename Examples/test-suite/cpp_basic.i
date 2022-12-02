/* This is a basic test of proxy classes */

%warnfilter(SWIGWARN_TYPEMAP_SWIGTYPELEAK);                   /* memory leak when setting a ptr/ref variable */

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) global_cint;       /* Ruby, wrong constant name */

%feature("php:allowdynamicproperties", 1) Foo; /* Allow PHP-specific custom property testing in _runme.php */

%module cpp_basic

%newobject Bar::testFoo;

%{
#if defined(__SUNPRO_CC)
#pragma error_messages (off, wbadasg) /* Assigning extern "C" ... */
#endif
%}

%inline %{

class Foo {
  public:
    Foo(int a) : num(a) {}
    int num;

    int func1(int a) {
      return 2*a*num;
    }
    
    int func2(int a) {
      return -a*num;
    }
    
    int (Foo::*func_ptr)(int);

    const char* __str__() const { return "Foo"; }
};

class FooSub : public Foo {
  public:
    FooSub() :Foo(42) {}
};

class FooSubSub : public FooSub {
  public:
    FooSubSub() : FooSub() {}
    const char* __str__() const { return "FooSubSub"; }
};

Foo& get_reference(Foo& other) { return other; }
const Foo& get_const_reference(const Foo& other) { return other; }

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
/* Const member data and references mean this class can't be assigned.
private:
    Bar& operator=(const Bar&);
*/
};

// This class is valid C++ but cannot be assigned to because it has const member data.
struct JustConst {
explicit JustConst(int i_inp) : i(i_inp) {}
const int i;
};

%}

%{
Foo *Bar::global_fptr = NULL;
Foo &Bar::global_fref = init_ref;
Foo Bar::global_fval = Foo(3);
%}

/* member function tests */
%inline %{
int (Foo::*get_func1_ptr())(int) {
  return &Foo::func1;
}

int (Foo::*get_func2_ptr())(int) {
  return &Foo::func2;
}

int test_func_ptr(Foo *f, int a) {
  return (f->*(f->func_ptr))(a);
}

%}


#ifdef __cplusplus
%define MACRO_WINDOW_SHOW
void show(void *count = 0, void *data = 0)
{
  return;
}
%enddef

%inline %{
  class Fl_Window {
  public:
    Fl_Window() {};
    ~Fl_Window() {};
  };
%}

%extend Fl_Window {
  MACRO_WINDOW_SHOW
}

#endif
