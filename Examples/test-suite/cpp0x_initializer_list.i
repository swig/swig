/* This testcase checks whether SWIG correctly uses the new initializer_list
   introduced in C++0x. */
%module cpp0x_initializer_list
%warnfilter(520) A;

%inline %{
#include <initializer_list>

class A {
public:
  A( std::initializer_list<int> ) {}
  A() {}
};
%}

