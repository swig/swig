%module(directors="1") director_exception
%{

#include <string>

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() { return "Foo::ping()"; }
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

Foo *launder(Foo *f) {
	return f;
}

// define dummy director exception classes to prevent spurious errors 
// in target languages that do not support directors.

#ifndef SWIG_DIRECTORS
class SWIG_DIRECTOR_EXCEPTION {};
class SWIG_DIRECTOR_METHOD_EXCEPTION: public SWIG_DIRECTOR_EXCEPTION {};
  #ifndef SWIG_fail
    #define SWIG_fail
  #endif
#endif

%}

%include "typemaps.i"
%include "exception.i"
%include "std_string.i"


%feature("director:except") {
	if ($error != NULL) {
		throw SWIG_DIRECTOR_METHOD_EXCEPTION();
	}
}

%exception {
	try { $action }
	catch (SWIG_DIRECTOR_EXCEPTION &e) { SWIG_fail; }
}


%feature("director") Foo;

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() { return "Foo::ping()"; }
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

Foo *launder(Foo *f);

