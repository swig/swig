// This module tests various facets of the %rename directive

%module rname

/* Applied everywhere */
%rename(foo_i) foo(int);
%rename(foo_d) foo(double);

/* Applied only to global scope */

%rename(foo_s) ::foo(short);

/* Applied only to class scope */

%rename(foo_u) *::foo(unsigned);

/* Rename classes in a class hierarchy */
%rename (RenamedBase) Base;
%rename (RenamedDerived) Derived;

%inline %{
class Bar {
public:
   char *foo(int)      { return (char *) "Bar::foo-int"; }
   char *foo(double)   { return (char *) "Bar::foo-double"; }
   char *foo(short)    { return (char *) "Bar::foo-short"; }
   char *foo(unsigned) { return (char *) "Bar::foo-unsigned"; }
};

char *foo(int)      { return (char *) "foo-int"; }
char *foo(double)   { return (char *) "foo-double"; }
char *foo(short)    { return (char *) "foo-short"; }
char *foo(unsigned) { return (char *) "foo-unsigned"; }

class Base {
public: 
  Base(){}; 
  virtual ~Base(){};
};
class Derived : public Base {
public:
  Derived(){}
  ~Derived(){}
  void fn(Derived derived, Base* basePtr, Base& baseRef){} // test renamed classes in a function
};


%}
