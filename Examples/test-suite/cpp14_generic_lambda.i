%module cpp14_generic_lambda

// C++14 generic lambdas - lambdas with one or more 'auto' parameters.  Each auto parameter introduces an
// invented type template parameter at the C++ level. Lambdas are not directly wrapped, this test shows
// one way to make them available via a manually written C++ function wrapper.

%warnfilter(SWIGWARN_CPP11_LAMBDA);

%inline %{
// Single auto parameter.
auto twice = [](auto x) { return x + x; };

// Two auto parameters.
auto add = [](auto a, auto b) { return a + b; };

int run_twice(int x)        { return twice(x); }
int run_add(int a, int b)   { return add(a, b); }
%}
