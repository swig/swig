/* SF Bug #445219, submitted by Krzysztof Kozminski
   <kozminski@users.sf.net>. 

   Swig 1.3.6 gets confused by pure virtual destructors,
   as in this file:
*/

%module test

%inline %{

class A {
 public:
  A() {};
  virtual ~A() = 0;
  virtual void something() = 0;
};

%}
