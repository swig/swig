#ifndef DIRECTOR_H
#define DIRECTOR_H


#include <stdio.h>
#include <string>


class FooBarAbs
{
public:
	FooBarAbs() {};
	virtual ~FooBarAbs() {};

	std::string FooBar() {
		return this->Foo() + ", " + this->Bar();
	};

protected:
	virtual std::string Foo() {
		return "Foo";
	};

	virtual std::string Bar() = 0;
};


class FooBarCpp : public FooBarAbs
{
protected:
	virtual std::string Foo() {
		return "C++ " + FooBarAbs::Foo();
	}

	virtual std::string Bar() {
		return "C++ Bar";
	}
};


#endif
