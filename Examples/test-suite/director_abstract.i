%module(directors="1") director_abstract
%{
#include <string>

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() = 0;
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

%}

%include "typemaps.i"
%include "exception.i"
%include "std_string.i"

%feature("director") Foo;

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() = 0;
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};

