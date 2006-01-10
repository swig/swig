%module exception_order

%include "exception.i"

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

%throws(E1,E2*,ET<int>,ET<double>) A::barfoo(int i);


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

  template <class T>
  struct ET 
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


    int barfoo(int i)
    {
      if (i == 1) {
	throw E1();
      } else if (i == 2) {
	static E2 *ep = new E2();
	throw ep;
      } else if (i == 3) {
	throw ET<int>();
      } else  {
	throw ET<double>();
      }
      return 0;
    }
  };
%}

%template(ET_i) ET<int>;
%template(ET_d) ET<double>;
