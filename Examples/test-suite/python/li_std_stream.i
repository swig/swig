%module li_std_stream

%include <std_iostream.i>


%pythoncallback(1) A::bar;

%inline %{

  struct A 
  {
    void __add__(int a)
    {
    }

    void __add__(double a)
    {
    }

    static int bar(int a){
      return a;
    }

    static int foo(int a, int (*pf)(int a))
    {
      return pf(a);
    }
    
  };
  

%}
