%module exception_order

%include "exception.i"

#ifdef SWIGCSHARP
#undef %exception
#define %exception %csexception
#endif

/* 
   last resource, catch everything but don't override 
   user's throw declarations.
*/

%exception {
  try {
    $action
  } catch(...) {
    SWIG_exception(SWIG_RuntimeError,"postcatch unknown");
  }
}


%inline %{
  struct E1
  {
  };

  struct E2 
  {
  };

  struct E3 
  {
  };

  struct A 
  {
    /* caught by the user's throw definition */
    int foo() throw(E1) 
    {
      throw E1();
      return 0;     
    }
    
    int bar() throw(E2)
    {
      throw E2();
      return 0;     
    }
    
    /* caught by %postexception */
    int foobar()
    {
      throw E3();
      return 0;
    }
  };
%}
