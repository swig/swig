%module(directors="1") cpp11_director_using_constructor

// This testcase uses cpp11_using_constructor.i for testing that the expected
// constructors are available in director mode.

%feature("director");

%include "cpp11_using_constructor.i"
