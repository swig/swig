%module autodoc

%feature("autodoc","extended");

// especial typemap and its docs
%typemap(in) (int c, int d) "$1 =0; $2 = 0;";
%typemap(doc,name="hello",type="Tuple") (int c, int d) "hello: int tuple[2]";

%inline {

  enum Hola {
    hi, hello
  };
  
  struct A
  {
    A(int a, short b, Hola h)
    {
    }
    
    int func1(int c, int d)
    {
      return c;
    }
    

    int func2(A* c, double d = 2)
    {
      return 2;
    }
    
  }; 
}


// deleting typemaps and docs
%typemap(in) (int c, int d) ;
%typemap(doc) (int c, int d);

// docs for some parameters
%typemap(doc) int a "a: special comment for parameter a";
%typemap(doc) int b "b: another special comment for parameter b";

%pythoncallback(1) func_cb;

%inline {
  
  struct B
  {
    B(int a, int b, Hola h)
    {
    }
    
    
    int func(int c, int d)
    {
      return c;
    }
    
  }; 

  int func(int c, int d) {
    return c;
  }

  int funcio(int *INOUT) {
    return 1;
  }

  int func_cb(int c, int d) {
    return c;
  }
  
}
