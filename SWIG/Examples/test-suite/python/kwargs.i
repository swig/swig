%module kwargs

%feature("kwargs");

//
// No warnings nor overload methods should be generated here
//

%extend Foo 
{
  int efoo(int a =1, int b = 0) {return a + b; }
  static int sfoo(int a =1, int b = 0) { return a + b; }
}

%inline %{


  int foo(int a =1, int b = 0) {return a + b; }
  
      

  struct Foo 
  {
    Foo(int a, int b = 0){}

    int foo(int a =1, int b = 0) {return a + b; }
    static int bar(int a =1, int b = 0) {return a + b; }
  };

%}
