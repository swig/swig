%module exception_order

%warnfilter(SWIGWARN_RUBY_WRONG_NAME);

#if defined(SWIGGO) && defined(SWIGGO_GCCGO)
%{
#ifdef __GNUC__
#include <cxxabi.h>
#endif
%}
#endif

%include "exception.i"

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

/* 
   last resource, catch everything but don't override 
   user's throw declarations.
*/

#if defined(SWIGOCTAVE)
%exception {
  try {
    $action
  }
  SWIG_RETHROW_OCTAVE_EXCEPTIONS
  catch(...) {
    SWIG_exception(SWIG_RuntimeError,"postcatch unknown");
  }
}
#elif defined(SWIGUTL)
%exception {
  try {
    $action
  } catch(...) {
    SWIG_exception_fail(SWIG_RuntimeError,"postcatch unknown");
  }
}
#elif defined(SWIGGO) && defined(SWIGGO_GCCGO)
%exception %{
  try {
    $action
#ifdef __GNUC__
  } catch (__cxxabiv1::__foreign_exception&) {
    throw;
#endif
  } catch(...) {
    SWIG_exception(SWIG_RuntimeError,"postcatch unknown");
  }
%}
#else
%exception {
  try {
    $action
  } catch(...) {
    SWIG_exception(SWIG_RuntimeError,"postcatch unknown");
  }
}
#endif

%catches(E1,E2*,ET<int>,ET<double>,...) A::barfoo(int i);


%allowexception efoovar;
%allowexception A::efoovar;

%inline %{
  int efoovar;
  int foovar;
  const int cfoovar = 1;
  
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
    static int sfoovar;
    static const int CSFOOVAR = 1;
    int foovar;
    int efoovar;

    /* caught by the user's throw definition */
    int foo() TESTCASE_THROW1(E1)
    {
      throw E1();
      return 0;
    }

    int bar() TESTCASE_THROW1(E2)
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
  int A::sfoovar = 1;

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif

%}

%template(ET_i) ET<int>;
%template(ET_d) ET<double>;

