//%module(ruby_minherit="1") multiple_inheritance
%module(directors="1") director_multiple_inheritance

%feature("director") A;
%feature("director") B;
%feature("director") C;
%feature("director") D;

%inline %{

class A {
public:
    virtual ~A() { }
    virtual int testA();
};

class B: virtual public A {
public:
    virtual ~B() { }
    virtual int testB();
};

class C: virtual public A {
public:
    virtual ~C() { }
    virtual int testC();
};

class D: virtual public A {
public:
    virtual ~D() { }
    virtual int testD();
};

class E {
public:
    virtual ~E() { }
    virtual int testE(B*);
};

class F {
public:
    virtual ~F() { }
    virtual int testF(C*);
};

class T {
public:
    virtual ~T() { }
    virtual int testT(D*);
};

%}

%{

int A::testA() { return 1; }

int B::testB() { return 2; }

int C::testC() { return 3; }

int D::testD() { return 4; }

int E::testE(B*) { return 5; }

int F::testF(C*) { return 6; }

int T::testT(D*) { return 20; }

%}
