%module cpp20_lambda_template

// We just want to test that SWIG doesn't choke parsing this so suppress:
// Warning 340: Lambda expressions and closures are not fully supported yet.
%warnfilter(SWIGWARN_CPP11_LAMBDA);

%include <std_vector.i>

%inline %{
#include <vector>
auto templated_lambda = []<typename T>(std::vector<T> t){};

// Regression test for parsing bug fixed in SWIG 4.2.0 (#2630)
auto y = []<bool X = 1>=2> { return 1; };
auto z = []<bool X = 1<=2> { return 1; };
%}
