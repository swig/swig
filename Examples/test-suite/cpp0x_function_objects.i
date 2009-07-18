/* This testcase checks whether Swig correctly parses function objects
   and the templates for the functions (signature).
   Function objects are objects which overload the operator() function. */
%module cpp0x_function_objects

%inline %{
//function<int ( int, int )> pF; // not supported yet by the compiler

struct Test {
  int value;
  
  void operator()(short x, short y) {
    value=10;
  }
  
} test;
%}

