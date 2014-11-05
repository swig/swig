%module overload_polymorphic

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
