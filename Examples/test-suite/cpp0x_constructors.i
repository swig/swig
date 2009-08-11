/* This test checks whether Swig correctly parses the new delegating
   constructors and constructor inheritance.
*/
%module cpp0x_constructors

%inline %{
class BaseClass {
private:
	int _val;
public:
	BaseClass(int iValue) { _val = iValue; }
};

class DerivedClass: public BaseClass {
public:
	using BaseClass::BaseClass; // Adds DerivedClass(int) constructor
};

class A {
public:
        int a;
        int b;
        int c;
        
        A() : A( 10 ) {}
        A(int aa) : A(aa, 20) {}
        A(int aa, int bb) : A(aa, bb, 30) {}
        A(int aa, int bb, int cc) { a=aa; b=bb; c=cc; }
};
%}
