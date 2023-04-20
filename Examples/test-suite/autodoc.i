%module(docstring="hello.") autodoc

%warnfilter(SWIGWARN_PARSE_KEYWORD) inout;

%feature("autodoc");

// special typemap and its docs
%typemap(in) (int c, int d) "$1 = 0; $2 = 0;"
%typemap(doc,name="hello",type="Tuple") (int c, int d) "hello: int tuple[2]"

// testing for different documentation levels
%feature("autodoc","0") A::func0; // names
%feature("autodoc","1") A::func1; // names + types
%feature("autodoc","2") A::func2; // extended 
%feature("autodoc","3") A::func3; // extended + types

%feature("autodoc","0") A::func0default; // names
%feature("autodoc","1") A::func1default; // names + types
%feature("autodoc","2") A::func2default; // extended 
%feature("autodoc","3") A::func3default; // extended + types

%feature("autodoc","0") A::func0static; // names
%feature("autodoc","1") A::func1static; // names + types
%feature("autodoc","2") A::func2static; // extended 
%feature("autodoc","3") A::func3static; // extended + types

%feature("autodoc","0") A::variable_a; // names
%feature("autodoc","1") A::variable_b; // names + types
%feature("autodoc","2") A::variable_c; // extended
%feature("autodoc","3") A::variable_d; // extended + types

%feature("autodoc","just a string.") A::funk; // names

%inline {

  enum Hola {
    hi, hello
  };
  
  struct A {
    A(int a, short b, Hola h) {}
    int funk(int a) { return a; }

    int func0(short, int c, int d) { return c; }
    int func1(short, int c, int d) { return c; }    
    int func2(short, int c, int d) { return c; }
    int func3(short, int c, int d) { return c; }

    int func0default(A *e, short, int c, int d, double f = 2) { return 0; }
    int func1default(A *e, short, int c, int d, double f = 2) { return 0; }    
    int func2default(A *e, short, int c, int d, double f = 2) { return 0; }
    int func3default(A *e, short, int c, int d, double f = 2) { return 0; }

    static int func0static(A *e, short, int c, int d, double f = 2) { return 0; }
    static int func1static(A *e, short, int c, int d, double f = 2) { return 0; }    
    static int func2static(A *e, short, int c, int d, double f = 2) { return 0; }
    static int func3static(A *e, short, int c, int d, double f = 2) { return 0; }

    int variable_a;
    int variable_b;
    int variable_c;
    int variable_d;
  }; 
}


// deleting typemaps and docs
%typemap(in) (int c, int d) ;
%typemap(doc) (int c, int d);

// docs for some parameters
%typemap(doc) int a "a: special comment for parameter a"
%typemap(doc) int b "b: another special comment for parameter b"

%feature("autodoc","0") C::C(int a, int b, Hola h); // names
%feature("autodoc","1") D::D(int a, int b, Hola h); // names + types
%feature("autodoc","2") E::E(int a, int b, Hola h); // extended
%feature("autodoc","3") F::F(int a, int b, Hola h); // extended + types
%feature("autodoc","0") C::~C(); // names
%feature("autodoc","1") D::~D(); // names + types
%feature("autodoc","2") E::~E(); // extended
%feature("autodoc","3") F::~F(); // extended + types

%inline {
  
  struct B {
    B(int a, int b, Hola h) {}
    int funk(int c, int d) { return c; }
  }; 

  struct C {
    C(int a, int b, Hola h) {}
  }; 
  struct D {
    D(int a, int b, Hola h) {}
  }; 
  struct E {
    E(int a, int b, Hola h) {}
  }; 
  struct F {
    F(int a, int b, Hola h) {}
  }; 

  int funk(A *e, short, int c, int d) { return c; }
  int funkdefaults(A *e, short, int c, int d, double f = 2) { return c; }
}

%include <typemaps.i>
%inline %{
  int func_input(int *INPUT) {
    return 1;
  }
  int func_output(int *OUTPUT) {
    *OUTPUT = 2;
    return 1;
  }
  int func_inout(int *INOUT) {
    *INOUT += 1;
    return 1;
  }
%}

%callback("%(uppercase)s_CALLBACK") func_cb;

%inline {
  int func_cb(int c, int d) { return c; }
}

// Bug 3310528
%feature("autodoc","1") banana; // names + types
%inline %{
typedef struct tagS {
  int a;
  char b;
} S;

typedef int Integer;

void banana(S *a, const struct tagS *b, int c, Integer d) {}
%}

// Check docs for a template type
%inline %{
template<typename X> struct T {
  T inout(T t) { return t; }
};
%}
%template(TInteger) T<int>;

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

// Autodoc language keywords
%feature(autodoc,1) process;
%feature(autodoc,1) process2;
%feature("compactdefaultargs") process;
%feature("compactdefaultargs") process2;
%inline %{
int process(int from, int in, int var) { return from; }
int process2(int from = 0, int _in = 1, int var = 2) { return from; }
%}

%feature(autodoc,1) process3;
%feature(autodoc,1) process4;
%feature("kwargs") process3;
%feature("kwargs") process4;
%inline %{
int process3(int from, int _in, int var) { return from; }
int process4(int from = 0, int _in = 1, int var = 2) { return from; }
%}

// Autodoc for methods with default arguments not directly representable in
// target language.
%feature(autodoc,0) process_complex_defval;
%feature("compactdefaultargs") process_complex_defval;
%inline %{
const int PROCESS_DEFAULT_VALUE = 17;
typedef long int some_type;
int process_complex_defval(int val = PROCESS_DEFAULT_VALUE, int factor = some_type(-1)) { return val*factor; }
%}

// Test for empty docstring, which should be ignored.
%feature("docstring") ""

%inline %{
struct a_structure{
  char my_array[1];
};
%}
