/* This testcase checks whether SWIG correctly uses the new initializer_list
   introduced in C++0x. */
%module cpp0x_initializer_list
%warnfilter(SWIGWARN_LANG_INITIALIZER_LIST) A;

%inline %{
#include <initializer_list>

class A {
public:
  A( std::initializer_list<int> ) {}
  A() {}
  A(double d) {}
};
class B {
public:
  B( std::initializer_list<int>, std::initializer_list<double> ) {}
  B() {}
  void method(std::initializer_list<int> init) {}
};
%}

