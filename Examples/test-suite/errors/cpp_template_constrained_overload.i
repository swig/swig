%module xxx

%inline %{
#include <concepts>

// C++20 abbreviated function templates told apart only by their type-constraint.
int classify(std::integral auto value) { return 1; }
double classify(std::floating_point auto value) { return 2; }
%}

%template(classify_int) classify<int>;
%template(classify_double) classify<double>;
