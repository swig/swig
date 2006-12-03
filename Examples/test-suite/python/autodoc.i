%module(docstring="hello") autodoc

%feature("autodoc");

// especial typemap and its docs
%typemap(in) (int c, int d) "$1 =0; $2 = 0;";
%typemap(doc,name="hello",type="Tuple") (int c, int d) "hello: int tuple[2]";

// testing for different documentation levels
%feature("autodoc","0") A::func0; // names
%feature("autodoc","1") A::func1; // names + types
%feature("autodoc","2") A::func2; // extended 
%feature("autodoc","3") A::func3; // extended + types

%feature("autodoc","just a string") A::func; // names

%inline {

  enum Hola {
    hi, hello
  };
  
  struct A
  {
    A(int a, short b, Hola h)
    {
    }

    int func(int a)
    {
      return a;
    }

    int func0(int c, int d)
    {
      return c;
    }
    
    int func1(int c, int d)
    {
      return c;
    }    

    int func2(A* c, double d = 2)
    {
      return 2;
    }

    int func3(A* c, double d = 2)
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

%callback(1) func_cb;

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
