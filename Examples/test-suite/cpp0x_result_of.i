/* This testcase checks whether Swig correctly uses the new result_of class
   and its templating capabilities introduced in C++0x. */
%module cpp0x_result_of

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
