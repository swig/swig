%module(directors="1") director_default
%{
#include <string>

class Foo {
public:
        Foo(int i = -1) {}
	virtual ~Foo() {}
	virtual std::string Msg(std::string msg = "default") { return "Foo-" + msg; }

	std::string GetMsg() { return Msg(); }
	std::string GetMsg(std::string msg) { return Msg(msg); }
};

%}

%include <std_string.i>

%feature("director") Foo;

class Foo {
public:
        Foo(int i = -1) {}
	virtual ~Foo() {}
	virtual std::string Msg(std::string msg = "default") { return msg; }

	std::string GetMsg() { return Msg(); }
	std::string GetMsg(std::string msg) { return Msg(msg); }
};


%inline %{
class Bar {
public:
        Bar() {}
        Bar(int i) {}
	virtual ~Bar() {}
	virtual std::string Msg(std::string msg = "default") { return "Bar-" + msg; }

	std::string GetMsg() { return Msg(); }
	std::string GetMsg(std::string msg) { return Msg(msg); }
};

%}
