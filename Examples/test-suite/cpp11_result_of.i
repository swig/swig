/* This testcase checks whether SWIG correctly uses the new result_of class
   and its templating capabilities introduced in C++11. */
%module cpp11_result_of

%inline %{
#include <functional>
#include <iostream>

double square(double x) {
  return (x * x);
}

template<class Fun, class Arg>
typename std::result_of<Fun(Arg)>::type test_result_impl(Fun fun, Arg arg) {
  return fun(arg);
}
%}

%template(test_result) test_result_impl<double(*)(double), double>;
%constant double (*SQUARE)(double) = square;
