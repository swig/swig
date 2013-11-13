/* This testcase checks whether SWIG correctly parses function objects
   and the templates for the functions (signature).
   Function objects are objects which overload the operator() function.
   The std::function does not provide any seamless support in the target languages yet.
*/
%module cpp11_function_objects

%rename(__call__) Test::operator();

%inline %{
struct Test {
  int value;
  
  void operator()(int x, int y) {
    value=x+y;
  }
  Test() : value(0) {}
} test;

#include <functional>
std::function<void ( int, int )> pF = test;

int testit1(Test new_test, int a, int b) {
  pF = new_test;
  pF(a, b);
  return new_test.value;
}

int testit2(int a, int b) {
  test(a, b);
  return test.value;
}

%}

