%module(directors="1") example
%feature("director");

%{
#include "example.h"
%}

%include "std_vector.i"

%include "example.h"

%template(VectorBar) std::vector<Bar*>;
%template(VectorFoo) std::vector<Foo*>;
