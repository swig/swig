// This module tests default constructor generation under a
// number of different conditions

%module default_constructor

%warnfilter(802, 813) EB; /* Ruby, Java multiple inheritance */
%warnfilter(802, 813) AD; /* Ruby, Java multiple inheritance */
%warnfilter(510) F; /* friend function */

%inline %{

/* A class with a public default constructor */
class A {
public:
   A() { };
};

/* This class should get default constructor/destructors */
class AA : public A {
};

/* A class with a public constructor, but not default */

class B {
private:
   B() { }
public:
   B(int x, int y) { }
};

/* This class should get no default constructor, but a destructor */
class BB : public B {
};

/* A class with a protected constructor */
class C {
protected:
    C() { };
public:
};

/* This class does get a default constructor/destructor */
class CC : public C {
};


/* A class with a private constructor */
class D {
private:
   D() { };
public:
   void foo() { };
};

/* This class does not get a default constructor */
class DD: public D {
	
};

/* No default constructor.  A is okay, but D is not */
class AD: public A, public D {

};

/* This class has a default constructor because of optional arguments */
class E {
public:
   E(int x = 0, int y = 0) { }
};

/* This should get a default constructor */
class EE : public E {
};

/* This class should not get a default constructor. B doesn't have one */

class EB : public E, public B {

};

/* A class with a private destructor */

class F {
private:
   ~F() { }
public:
   void foo(int, int) { }
   friend void bar(F *);
};

void bar(F *) { }

class FFF : public F { 
};

/* A class with a protected destructor */
class G {
protected:
   ~G() { }
};

class GG : public G { 
};

%}
 



