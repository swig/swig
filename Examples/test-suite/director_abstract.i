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

%include "std_string.i"

%feature("director") Foo;

class Foo {
public:
	virtual ~Foo() {}
	virtual std::string ping() = 0;
	virtual std::string pong() { return "Foo::pong();" + ping(); }
};



%feature("director") Example1;

%inline %{
class Example1
{
private:

protected:
 int xsize, ysize;
 int fontsize;
 int fontdim[23];


public:
 Example1()
   : xsize(200), ysize(200) { }

 virtual ~Example1() {}

 int  GetXSize() const { return xsize; }

 // pure virtual methods that must be overridden
 virtual int Color(unsigned char r, unsigned char g, unsigned char b) = 0;
};

%}
