%module inherit_void_arg

%inline %{

class A {
public:
	virtual void f(void) = 0;
};

class B : public A {
public:
        void f() { }
};

%}

