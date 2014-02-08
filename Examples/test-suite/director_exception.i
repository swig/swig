%module(directors="1") director_exception

%{

#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif

#include <string>


// define dummy director exception classes to prevent spurious errors 
// in target languages that do not support directors.

#ifndef SWIG_DIRECTORS
namespace Swig {
class DirectorException {};
class DirectorMethodException: public Swig::DirectorException {};
}
  #ifndef SWIG_fail
    #define SWIG_fail
  #endif
#endif /* !SWIG_DIRECTORS */

%}

%include "std_string.i"

#ifdef SWIGPYTHON

%feature("director:except") {
	if ($error != NULL) {
		throw Swig::DirectorMethodException();
	}
}

%exception {
	try { $action }
	catch (Swig::DirectorException &) { SWIG_fail; }
}

#endif

#ifdef SWIGJAVA

// Default for director exception warns about unmapped exceptions now in java
// Suppress warnings for this older test
// %warnfilter(476) Bar;

// Default for java is to throw Swig::DirectorException if no
// direct:except feature.  Since methods below have exception specification
// cannot throw director exception.

// Change back to old 2.0 default behavior

%feature("director:except") {
	jthrowable $error = jenv->ExceptionOccurred();
	if ($error) {
	  // Dont clear exception, still be active when return to java execution
	  // Essentially ignore exception occurred -- old behavior.
	  return $null;
	}
}

#endif

#ifdef SWIGRUBY

%feature("director:except") {
    throw Swig::DirectorMethodException($error);
}

%exception {
  try { $action }
  catch (Swig::DirectorException &e) { rb_exc_raise(e.getError()); }
}

#endif

%feature("director") Foo;

%inline {

class Foo {
public:
  virtual ~Foo() {}
  virtual std::string ping() { return "Foo::ping()"; }
  virtual std::string pong(int val=3) { return "Foo::pong();" + ping(); }
};

Foo *launder(Foo *f) {
  return f;
}

}


%{
  struct Unknown1
  {
  };

  struct Unknown2
  {
  };
%}

%feature("director") Bar;


%inline %{
  struct Exception1
  {
  };

  struct Exception2
  {
  };

  class Base 
  {
  public:
    virtual ~Base() throw () {}
  };
  

  class Bar : public Base
  {
  public:
    virtual std::string ping() throw (Exception1, Exception2&) { return "Bar::ping()"; }
    virtual std::string pong() throw (Unknown1, int, Unknown2&) { return "Bar::pong();" + ping(); }
    virtual std::string pang() throw () { return "Bar::pang()"; }
  };
  
%}
