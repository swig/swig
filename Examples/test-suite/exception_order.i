%module exception_order

%include "exception.i"

#if 1
%exception {
    try {
        $action
    } catch(...) {
        SWIG_exception(SWIG_RuntimeError,"Unknown exception");
    }
}

#endif

%inline %{
  

  struct E
  {
  };

  struct A 
  {
   int foo() throw(E)
   {
     throw E();
     return 0;     
   }
  };
%}
