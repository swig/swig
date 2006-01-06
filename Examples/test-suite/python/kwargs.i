%module kwargs

%kwargs;

%inline 
{
  struct s { int a; };
}


// Simple class
%extend Foo 
{
  int efoo(int a = 1, int b = 0) {return a + b; }
  static int sfoo(int a = 1, int b = 0) { return a + b; }
}

%newobject Foo::create;

%inline %{

  struct Foo 
  {
    Foo(int a, int b = 0) {}

    virtual int foo(int a = 1, int b = 0) {return a + b; }
    static int statfoo(int a = 1, int b = 0) {return a + b; }

    static Foo *create(int a = 1, int b = 0) 
    {
      return new Foo(a, b);
    }

    virtual ~Foo() {
    }
    
  };

%}


// Templated class
%extend Bar 
{
  T ebar(T a = 1, T b = 0) {return a + b; }
  static T sbar(T a = 1, T b = 0) { return a + b; }
}

%inline %{
  template <typename T> struct Bar 
  {
    Bar(T a, T b = 0){}

    T bar(T a = 1, T b = 0) {return a + b; }
    static T statbar(T a = 1, T b = 0) {return a + b; }
  };

%}

%template(BarInt) Bar<int>;


// Functions
%inline %{
  int foo(int a = 1, int b = 0) {return a + b; }

  
  template<typename T> T templatedfunction(T a = 1, T b = 0) { return a + b; }
%}

%template(templatedfunction) templatedfunction<int>;


// Deafult args with references
%inline
%{

  typedef int size_type;
  
  struct Hello 
  {
    static const size_type hello = 3;
  };
  
  
  
  int rfoo( const size_type& x = Hello::hello, const Hello& y = Hello() )
  {
    return x;
  }
  
%}
%{
  const int Hello::hello;
%}
  

// Functions with keywords
%warnfilter(SWIGWARN_PARSE_KEYWORD);
%inline %{
  /* silently rename the parameter names in python */

  int foo_kw(int from = 1, int except = 2) {return from + except; }


  int foo_nu(int from = 1, int = 0) {return from; }

%}
