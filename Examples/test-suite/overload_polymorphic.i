%module overload_polymorphic

#ifndef SWIG_NO_OVERLOAD

%inline %{

class Base {
public:
	Base(){}
	virtual ~Base(){}
};

class Derived : public Base {
public:
	Derived(){}
	virtual ~Derived(){}
};



int test(Base* base){ return 0;}
int test(int hello){ return 1; }

%}
#endif
